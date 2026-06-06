pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: root

    property bool loaded: false
    property string draft: ""
    property int modelVersion: 0
    property var subtaskDrafts: ({})
    property string editingTodoId: ""
    property string editingSubtaskId: ""
    property string editingDraft: ""

    readonly property bool needsKeyboard: true
    readonly property string storagePath: `${Paths.state}/todos.json`
    readonly property bool canAddTodo: normalizedText(draft).length > 0
    readonly property int completedCount: {
        modelVersion;
        let count = 0;
        for (let i = 0; i < todosModel.count; i++) {
            if (todosModel.get(i).done)
                count++;
        }
        return count;
    }

    implicitWidth: 860
    implicitHeight: 520

    function normalizedText(text: string): string {
        return text.replace(/\s+/g, " ").trim();
    }

    function makeId(): string {
        return `${Date.now()}-${Math.floor(Math.random() * 1000000)}`;
    }

    function markDirty(): void {
        sortTodosUncheckedFirst();
        modelVersion++;
        saveTimer.restart();
    }

    function indexOfTodoId(todoId: string): int {
        for (let i = 0; i < todosModel.count; i++) {
            if (todosModel.get(i).todoId === todoId)
                return i;
        }

        return -1;
    }

    function sortTodosUncheckedFirst(): void {
        const rows = [];

        for (let i = 0; i < todosModel.count; i++) {
            const item = todosModel.get(i);
            rows.push({
                    todoId: item.todoId,
                    task: item.task,
                    done: item.done,
                    expanded: item.expanded,
                    createdAt: item.createdAt ?? Date.now(),
                    subtasks: sanitizeSubtasks(item.subtasks),
                    originalIndex: i
                });
        }

        rows.sort((a, b) => {
            if (a.done !== b.done)
                return a.done ? 1 : -1;
            return a.originalIndex - b.originalIndex;
        });

        let changed = false;
        for (let i = 0; i < rows.length; i++) {
            if (rows[i].originalIndex !== i) {
                changed = true;
                break;
            }
        }

        if (!changed)
            return;

        todosModel.clear();
        for (const row of rows) {
            delete row.originalIndex;
            todosModel.append(syncTodo(row));
        }
    }

    function subtaskArray(items: var): var {
        const result = [];

        if (Array.isArray(items)) {
            for (const item of items)
                result.push(item);
            return result;
        }

        const count = Number(items?.count ?? -1);
        if (count >= 0 && items?.get) {
            for (let i = 0; i < count; i++)
                result.push(items.get(i));
        }

        return result;
    }

    function sanitizeSubtasks(items: var): var {
        const result = [];
        let originalIndex = 0;
        for (const item of subtaskArray(items)) {
            const title = normalizedText(String(item?.title ?? ""));
            if (!title) {
                originalIndex++;
                continue;
            }

            result.push({
                    id: String(item?.id ?? makeId()),
                    title,
                    done: !!item?.done,
                    originalIndex
                });
            originalIndex++;
        }

        result.sort((a, b) => {
            if (a.done !== b.done)
                return a.done ? 1 : -1;
            return a.originalIndex - b.originalIndex;
        });

        for (const item of result)
            delete item.originalIndex;

        return result;
    }

    function syncTodo(todo: var): var {
        const subtasks = sanitizeSubtasks(todo?.subtasks);
        const hasSubtasks = subtasks.length > 0;
        const done = hasSubtasks ? subtasks.every(subtask => subtask.done) : !!todo?.done;

        return {
            todoId: String(todo?.todoId ?? makeId()),
            task: normalizedText(String(todo?.task ?? "")),
            done,
            expanded: !!todo?.expanded,
            createdAt: Number(todo?.createdAt ?? Date.now()),
            subtasks
        };
    }

    function patchTodo(index: int, changes: var): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const current = todosModel.get(index);
        const merged = {
            todoId: current.todoId,
            task: current.task,
            done: current.done,
            expanded: current.expanded,
            createdAt: current.createdAt,
            subtasks: current.subtasks
        };

        for (const key of Object.keys(changes))
            merged[key] = changes[key];

        todosModel.set(index, syncTodo(merged));
        markDirty();
    }

    function setExpandedExclusive(index: int, expanded: bool): void {
        if (index < 0 || index >= todosModel.count)
            return;

        let changed = false;

        for (let i = 0; i < todosModel.count; i++) {
            const todo = todosModel.get(i);
            const shouldExpand = expanded && i === index;

            if (todo.expanded !== shouldExpand) {
                const merged = {
                    todoId: todo.todoId,
                    task: todo.task,
                    done: todo.done,
                    expanded: shouldExpand,
                    createdAt: todo.createdAt,
                    subtasks: todo.subtasks
                };
                todosModel.set(i, syncTodo(merged));
                changed = true;
            }

            if (i !== index || !shouldExpand)
                clearSubtaskDraft(todo.todoId);

            if ((i !== index || !shouldExpand) && editingTodoId === todo.todoId)
                stopEditing();

        }

        if (changed)
            markDirty();
    }

    function getSubtaskDraft(todoId: string): string {
        return subtaskDrafts[todoId] ?? "";
    }

    function setSubtaskDraft(todoId: string, text: string): void {
        const nextDrafts = {};
        for (const key of Object.keys(subtaskDrafts))
            nextDrafts[key] = subtaskDrafts[key];
        nextDrafts[todoId] = text;
        subtaskDrafts = nextDrafts;
    }

    function clearSubtaskDraft(todoId: string): void {
        const nextDrafts = {};
        for (const key of Object.keys(subtaskDrafts))
            nextDrafts[key] = subtaskDrafts[key];
        delete nextDrafts[todoId];
        subtaskDrafts = nextDrafts;
    }

    function isEditingTodo(todoId: string): bool {
        return editingTodoId === todoId && editingSubtaskId === "";
    }

    function isEditingSubtask(todoId: string, subtaskId: string): bool {
        return editingTodoId === todoId && editingSubtaskId === subtaskId;
    }

    function stopEditing(): void {
        editingTodoId = "";
        editingSubtaskId = "";
        editingDraft = "";
    }

    function startTodoEdit(index: int): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const todo = todosModel.get(index);
        editingTodoId = todo.todoId;
        editingSubtaskId = "";
        editingDraft = todo.task;
    }

    function startSubtaskEdit(index: int, subIndex: int): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const todo = todosModel.get(index);
        const todoSubtasks = sanitizeSubtasks(todo.subtasks);
        if (subIndex < 0 || subIndex >= todoSubtasks.length)
            return;

        const subtask = todoSubtasks[subIndex];
        editingTodoId = todo.todoId;
        editingSubtaskId = subtask.id;
        editingDraft = subtask.title;
        setExpandedExclusive(index, true);
    }

    function commitTodoEdit(index: int): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const todo = todosModel.get(index);
        if (!isEditingTodo(todo.todoId))
            return;

        const task = normalizedText(editingDraft);
        if (task && task !== todo.task)
            patchTodo(index, { task });

        stopEditing();
    }

    function commitSubtaskEdit(index: int, subIndex: int): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const todo = todosModel.get(index);
        const todoSubtasks = sanitizeSubtasks(todo.subtasks);
        if (subIndex < 0 || subIndex >= todoSubtasks.length)
            return;

        const subtask = todoSubtasks[subIndex];
        if (!isEditingSubtask(todo.todoId, subtask.id))
            return;

        const title = normalizedText(editingDraft);
        if (title && title !== subtask.title) {
            const nextSubtasks = [];
            for (let i = 0; i < todoSubtasks.length; i++) {
                const current = todoSubtasks[i];
                nextSubtasks.push({
                        id: current.id,
                        title: i === subIndex ? title : current.title,
                        done: current.done
                    });
            }

            patchTodo(index, { subtasks: nextSubtasks });
        }

        stopEditing();
    }

    function addTodo(): void {
        const task = normalizedText(draft);
        if (!task)
            return;

        todosModel.insert(0, syncTodo({
                    todoId: makeId(),
                    task,
                    done: false,
                    expanded: false,
                    createdAt: Date.now(),
                    subtasks: []
                }));
        draft = "";
        input.clear();
        Qt.callLater(() => input.forceActiveFocus());
        markDirty();
    }

    function toggleTodo(index: int): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const todo = todosModel.get(index);
        const todoSubtasks = sanitizeSubtasks(todo.subtasks);
        if (todoSubtasks.length > 0) {
            setExpandedExclusive(index, !todo.expanded);
            return;
        }

        patchTodo(index, {
                    done: !todo.done
                });
    }

    function toggleExpanded(index: int): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const todo = todosModel.get(index);
        setExpandedExclusive(index, !todo.expanded);
    }

    function removeTodo(index: int): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const todoId = todosModel.get(index).todoId;
        clearSubtaskDraft(todoId);
        if (editingTodoId === todoId)
            stopEditing();
        todosModel.remove(index, 1);
        markDirty();
    }

    function addSubtask(index: int): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const todo = todosModel.get(index);
        const todoId = todo.todoId;
        const title = normalizedText(getSubtaskDraft(todo.todoId));
        if (!title)
            return;

        const nextSubtasks = sanitizeSubtasks(todo.subtasks);
        nextSubtasks.push({
                id: makeId(),
                title,
                done: false
            });

        patchTodo(index, {
                    expanded: true,
                    subtasks: nextSubtasks
                });
        setExpandedExclusive(indexOfTodoId(todoId), true);
        clearSubtaskDraft(todoId);
    }

    function toggleSubtask(index: int, subIndex: int): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const todo = todosModel.get(index);
        const todoSubtasks = sanitizeSubtasks(todo.subtasks);
        if (subIndex < 0 || subIndex >= todoSubtasks.length)
            return;

        if (isEditingSubtask(todo.todoId, todoSubtasks[subIndex].id))
            stopEditing();

        const nextSubtasks = [];
        for (let i = 0; i < todoSubtasks.length; i++) {
            const subtask = todoSubtasks[i];
            nextSubtasks.push({
                    id: subtask.id,
                    title: subtask.title,
                    done: i === subIndex ? !subtask.done : subtask.done
                });
        }

        patchTodo(index, {
                    subtasks: nextSubtasks
                });
    }

    function removeSubtask(index: int, subIndex: int): void {
        if (index < 0 || index >= todosModel.count)
            return;

        const todo = todosModel.get(index);
        const todoSubtasks = sanitizeSubtasks(todo.subtasks);
        if (subIndex < 0 || subIndex >= todoSubtasks.length)
            return;

        const nextSubtasks = [];
        for (let i = 0; i < todoSubtasks.length; i++) {
            if (i !== subIndex)
                nextSubtasks.push(todoSubtasks[i]);
        }

        patchTodo(index, {
                    subtasks: nextSubtasks
                });
    }

    function clearDone(): void {
        for (let i = todosModel.count - 1; i >= 0; i--) {
            if (todosModel.get(i).done)
                todosModel.remove(i, 1);
        }
        markDirty();
    }

    function saveTodos(): void {
        if (!loaded)
            return;

        const out = [];
        for (let i = 0; i < todosModel.count; i++) {
            const item = todosModel.get(i);
            out.push({
                    todoId: item.todoId,
                    task: item.task,
                    done: item.done,
                    expanded: item.expanded,
                    createdAt: item.createdAt ?? Date.now(),
                    subtasks: sanitizeSubtasks(item.subtasks)
                });
        }
        storage.setText(JSON.stringify(out));
    }

    function focusPrimaryInput(): void {
        Qt.callLater(() => input.forceActiveFocus());
    }

    Timer {
        id: saveTimer

        interval: 300
        onTriggered: root.saveTodos()
    }

    ListModel {
        id: todosModel
    }

    FileView {
        id: storage

        path: root.storagePath
        printErrors: false

        onLoaded: {
            todosModel.clear();

            try {
                const data = JSON.parse(text());
                if (Array.isArray(data)) {
                    for (const row of data) {
                        const todo = root.syncTodo(row);
                        if (!todo.task)
                            continue;
                        todosModel.append(todo);
                    }
                }
            } catch (err) {
                console.warn("todo parse failed", err);
            }

            root.loaded = true;
            root.sortTodosUncheckedFirst();
            root.modelVersion++;
            Qt.callLater(() => root.saveTodos());
        }

        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                root.loaded = true;
                root.modelVersion++;
                Qt.callLater(() => {
                    setText("[]");
                    root.saveTodos();
                });
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.normal

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: controls.implicitHeight + Tokens.padding.normal * 2
            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.large

            RowLayout {
                id: controls

                anchors.fill: parent
                anchors.margins: Tokens.padding.normal
                spacing: Tokens.spacing.small

                StyledInputField {
                    id: input

                    Layout.fillWidth: true
                    text: root.draft
                    placeholderText: qsTr("Add a task and press Enter")
                    horizontalAlignment: TextInput.AlignLeft
                    Component.onCompleted: root.focusPrimaryInput()
                    onTextEdited: text => root.draft = text
                    onEditingFinished: root.addTodo()
                }

                StyledText {
                    text: qsTr("%1 tasks").arg(todosModel.count)
                    color: Colours.palette.m3onSurfaceVariant
                }

                IconButton {
                    icon: "add"
                    disabled: !root.canAddTodo
                    onClicked: root.addTodo()
                }

                IconButton {
                    icon: "cleaning_services"
                    type: IconButton.Tonal
                    disabled: root.completedCount === 0
                    onClicked: root.clearDone()
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.large
            clip: true

            Item {
                anchors.fill: parent
                anchors.margins: Tokens.padding.normal

                StyledListView {
                    id: list

                    anchors.fill: parent
                    model: todosModel
                    spacing: Tokens.spacing.small
                    clip: true

                    StyledScrollBar.vertical: StyledScrollBar {
                        flickable: list
                    }

                    delegate: StyledRect {
                        id: rowRoot

                        required property int index
                        required property string todoId
                        required property string task
                        required property bool done
                        required property bool expanded
                        required property var subtasks
                        readonly property var subtaskItems: root.sanitizeSubtasks(subtasks)
                        readonly property int subtaskTotal: subtaskItems.length
                        readonly property int subtaskDone: {
                            let count = 0;
                            for (const subtask of subtaskItems) {
                                if (subtask.done)
                                    count++;
                            }
                            return count;
                        }
                        readonly property real subtaskProgress: subtaskTotal > 0 ? subtaskDone / subtaskTotal : (done ? 1 : 0)

                        width: ListView.view.width
                        implicitHeight: contentColumn.implicitHeight + Tokens.padding.small * 2
                        color: rowRoot.done ? Colours.layer(Colours.palette.m3surfaceContainerHigh, 1) : Colours.layer(Colours.palette.m3surfaceContainer, 2)
                        radius: Tokens.rounding.normal

                        ColumnLayout {
                            id: contentColumn

                            anchors.fill: parent
                            anchors.margins: Tokens.padding.small
                            spacing: Tokens.spacing.small

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.small

                                IconButton {
                                    icon: rowRoot.done ? "check_circle" : "radio_button_unchecked"
                                    type: rowRoot.done ? IconButton.Filled : IconButton.Tonal
                                    onClicked: root.toggleTodo(rowRoot.index)
                                }

                                Item {
                                    Layout.fillWidth: true
                                    implicitHeight: taskMeta.implicitHeight

                                    StateLayer {
                                        radius: Tokens.rounding.small
                                        color: Colours.palette.m3onSurface
                                        onClicked: {
                                            if (!root.isEditingTodo(rowRoot.todoId))
                                                root.toggleExpanded(rowRoot.index);
                                        }
                                    }

                                    ColumnLayout {
                                        id: taskMeta

                                        anchors.fill: parent
                                        anchors.margins: Tokens.padding.small / 2
                                        spacing: 2

                                        StyledRect {
                                            Layout.fillWidth: true
                                            visible: root.isEditingTodo(rowRoot.todoId)
                                            implicitHeight: parentTaskInput.implicitHeight + Tokens.padding.small * 2
                                            color: Colours.layer(Colours.palette.m3surfaceContainer, 3)
                                            radius: Tokens.rounding.small
                                            border.width: 1
                                            border.color: Colours.palette.m3primary

                                            StyledTextField {
                                                id: parentTaskInput

                                                anchors.centerIn: parent
                                                width: parent.width - Tokens.padding.normal
                                                horizontalAlignment: TextInput.AlignLeft
                                                onTextChanged: root.editingDraft = text
                                                onEditingFinished: root.commitTodoEdit(rowRoot.index)
                                            }

                                            onVisibleChanged: {
                                                if (visible) {
                                                    parentTaskInput.text = rowRoot.task;
                                                    root.editingDraft = rowRoot.task;
                                                    Qt.callLater(() => {
                                                        parentTaskInput.forceActiveFocus();
                                                        parentTaskInput.cursorPosition = parentTaskInput.text.length;
                                                    });
                                                }
                                            }
                                        }

                                        StyledText {
                                            Layout.fillWidth: true
                                            visible: !root.isEditingTodo(rowRoot.todoId)
                                            text: rowRoot.task
                                            wrapMode: Text.Wrap
                                            color: rowRoot.done ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3onSurface
                                            font.strikeout: rowRoot.done
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            visible: !root.isEditingTodo(rowRoot.todoId) && rowRoot.subtaskTotal > 0
                                            spacing: Tokens.spacing.small

                                            StyledText {
                                                visible: rowRoot.subtaskTotal > 0
                                                text: qsTr("%1/%2 subtasks").arg(rowRoot.subtaskDone).arg(rowRoot.subtaskTotal)
                                                color: Colours.palette.m3onSurfaceVariant
                                                font.pointSize: Tokens.font.size.small
                                            }

                                            ProgressBar {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                visible: rowRoot.subtaskTotal > 0
                                                implicitHeight: 6
                                                value: rowRoot.subtaskProgress
                                                fgColor: rowRoot.done ? Colours.palette.m3tertiary : Colours.palette.m3primary
                                                bgColor: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
                                            }

                                        }
                                    }
                                }

                                IconButton {
                                    visible: rowRoot.expanded
                                    icon: root.isEditingTodo(rowRoot.todoId) ? "check" : "edit"
                                    type: IconButton.Text
                                    padding: Tokens.padding.small / 2
                                    font.pointSize: Tokens.font.size.normal
                                    onClicked: {
                                        if (root.isEditingTodo(rowRoot.todoId))
                                            root.commitTodoEdit(rowRoot.index);
                                        else
                                            root.startTodoEdit(rowRoot.index);
                                    }
                                }

                                IconButton {
                                    visible: rowRoot.expanded
                                    icon: "delete"
                                    type: IconButton.Text
                                    padding: Tokens.padding.small / 2
                                    font.pointSize: Tokens.font.size.normal
                                    onClicked: root.removeTodo(rowRoot.index)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: rowRoot.expanded
                                spacing: Tokens.spacing.small

                                StyledRect {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: Tokens.padding.large
                                    implicitHeight: subtaskColumn.implicitHeight + Tokens.padding.small * 2
                                    color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)
                                    radius: Tokens.rounding.normal

                                    StyledRect {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: 3
                                        radius: Tokens.rounding.full
                                        color: rowRoot.done ? Colours.palette.m3tertiary : Qt.alpha(Colours.palette.m3primary, 0.9)
                                    }

                                    ColumnLayout {
                                        id: subtaskColumn

                                        anchors.fill: parent
                                        anchors.margins: Tokens.padding.small
                                        anchors.leftMargin: Tokens.padding.normal + 6
                                        spacing: Tokens.spacing.smaller

                                        Repeater {
                                            model: rowRoot.subtaskItems

                                            delegate: ColumnLayout {
                                                required property int index
                                                required property var modelData

                                                Layout.fillWidth: true
                                                spacing: Tokens.spacing.smaller

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: Tokens.spacing.smaller

                                                    IconButton {
                                                        icon: modelData.done ? "check_circle" : "radio_button_unchecked"
                                                        type: modelData.done ? IconButton.Filled : IconButton.Tonal
                                                        padding: Tokens.padding.small / 3
                                                        font.pointSize: Tokens.font.size.normal
                                                        onClicked: root.toggleSubtask(rowRoot.index, index)
                                                    }

                                                    Item {
                                                        Layout.fillWidth: true
                                                        implicitHeight: subtaskEditInput.visible ? subtaskEditInput.implicitHeight : subtaskTextColumn.implicitHeight

                                                        StateLayer {
                                                            radius: Tokens.rounding.small
                                                            color: Colours.palette.m3onSurface
                                                            visible: !root.isEditingSubtask(rowRoot.todoId, modelData.id)
                                                            onClicked: root.startSubtaskEdit(rowRoot.index, index)
                                                        }

                                                        StyledRect {
                                                            anchors.fill: parent
                                                            visible: root.isEditingSubtask(rowRoot.todoId, modelData.id)
                                                            color: Colours.layer(Colours.palette.m3surfaceContainer, 3)
                                                            radius: Tokens.rounding.small
                                                            border.width: 1
                                                            border.color: Colours.palette.m3primary

                                                            StyledTextField {
                                                                id: subtaskEditInput

                                                                anchors.centerIn: parent
                                                                width: parent.width - Tokens.padding.normal
                                                                horizontalAlignment: TextInput.AlignLeft
                                                                onTextChanged: root.editingDraft = text
                                                                onEditingFinished: root.commitSubtaskEdit(rowRoot.index, index)
                                                            }

                                                            onVisibleChanged: {
                                                                if (visible) {
                                                                    subtaskEditInput.text = modelData.title;
                                                                    root.editingDraft = modelData.title;
                                                                    Qt.callLater(() => {
                                                                        subtaskEditInput.forceActiveFocus();
                                                                        subtaskEditInput.cursorPosition = subtaskEditInput.text.length;
                                                                    });
                                                                }
                                                            }
                                                        }

                                                        ColumnLayout {
                                                            id: subtaskTextColumn

                                                            anchors.fill: parent
                                                            visible: !root.isEditingSubtask(rowRoot.todoId, modelData.id)
                                                            spacing: 0

                                                            StyledText {
                                                                Layout.fillWidth: true
                                                                text: modelData.title
                                                                wrapMode: Text.Wrap
                                                                color: modelData.done ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3onSurface
                                                                font.strikeout: modelData.done
                                                                font.pointSize: Tokens.font.size.small
                                                            }

                                                        }
                                                    }

                                                    IconButton {
                                                        icon: "delete"
                                                        type: IconButton.Text
                                                        padding: Tokens.padding.small / 3
                                                        font.pointSize: Tokens.font.size.normal
                                                        onClicked: root.removeSubtask(rowRoot.index, index)
                                                    }
                                                }

                                            }
                                        }

                                        StyledText {
                                            visible: rowRoot.subtaskTotal === 0
                                            text: qsTr("No subtasks yet")
                                            color: Colours.palette.m3onSurfaceVariant
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: Tokens.spacing.small

                                            StyledInputField {
                                                id: subtaskInput

                                                Layout.fillWidth: true
                                                text: root.getSubtaskDraft(rowRoot.todoId)
                                                placeholderText: qsTr("Add a subtask")
                                                horizontalAlignment: TextInput.AlignLeft
                                                onTextEdited: text => root.setSubtaskDraft(rowRoot.todoId, text)
                                                onHasFocusChanged: {
                                                    if (!hasFocus && root.normalizedText(root.getSubtaskDraft(rowRoot.todoId)).length === 0)
                                                        root.clearSubtaskDraft(rowRoot.todoId);
                                                }
                                                onEditingFinished: {
                                                    root.addSubtask(rowRoot.index);
                                                    clear();
                                                    Qt.callLater(() => subtaskInput.forceActiveFocus());
                                                }
                                            }

                                            IconButton {
                                                icon: "add_task"
                                                padding: Tokens.padding.small / 3
                                                font.pointSize: Tokens.font.size.normal
                                                disabled: root.normalizedText(root.getSubtaskDraft(rowRoot.todoId)).length === 0
                                                onClicked: {
                                                    root.addSubtask(rowRoot.index);
                                                    subtaskInput.clear();
                                                    Qt.callLater(() => subtaskInput.forceActiveFocus());
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    visible: todosModel.count === 0
                    text: qsTr("No tasks yet. Add one above, then break it into subtasks when needed.")
                    color: Colours.palette.m3onSurfaceVariant
                    width: parent.width * 0.7
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    component ProgressBar: StyledRect {
        id: progressBar

        property real value: 0
        property color fgColor: Colours.palette.m3primary
        property color bgColor: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
        property real animatedValue: 0

        color: bgColor
        radius: Tokens.rounding.full
        Component.onCompleted: animatedValue = value
        onValueChanged: animatedValue = value

        StyledRect {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * progressBar.animatedValue
            color: progressBar.fgColor
            radius: Tokens.rounding.full
        }

        Behavior on animatedValue {
            Anim {
                type: Anim.StandardLarge
            }
        }
    }
}
