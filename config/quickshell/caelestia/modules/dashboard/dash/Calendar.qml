pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.effects
import qs.services

CustomMouseArea {
    id: root

    required property DashboardState dashState

    readonly property int currMonth: dashState.currentDate.getMonth()
    readonly property int currYear: dashState.currentDate.getFullYear()
    property var hoveredDate: null
    property Item hoveredItem: null
    property var selectedDate: null
    property string eventDraft: ""
    property int editingEventIndex: -1
    property string editingEventDraft: ""

    readonly property bool needsKeyboard: selectedDate !== null
    readonly property var selectedEvents: selectedDate ? CalendarEvents.listFor(selectedDate) : []
    readonly property var hoveredEvents: hoveredDate ? CalendarEvents.listFor(hoveredDate) : []

    function onWheel(event: WheelEvent): void {
        if (event.angleDelta.y > 0)
            root.dashState.currentDate = new Date(root.currYear, root.currMonth - 1, 1);
        else if (event.angleDelta.y < 0)
            root.dashState.currentDate = new Date(root.currYear, root.currMonth + 1, 1);
    }

    function sameDay(first: var, second: var): bool {
        return first && second && CalendarEvents.key(first) === CalendarEvents.key(second);
    }

    function dayLabel(date: var): string {
        return date ? Qt.formatDateTime(date, "ddd, MMM d") : "";
    }

    function addSelectedEvent(): void {
        if (!selectedDate || !eventDraft.trim())
            return;

        CalendarEvents.addEvent(selectedDate, eventDraft);
        eventDraft = "";
        eventInput.clear();
        cancelEventEdit();
        eventInput.forceActiveFocus();
    }

    function focusPrimaryInput(): void {
        if (selectedDate)
            Qt.callLater(() => eventInput.forceActiveFocus());
    }

    function startEventEdit(index: int, title: string): void {
        editingEventDraft = String(title ?? "");
        editingEventIndex = index;
    }

    function cancelEventEdit(): void {
        editingEventIndex = -1;
        editingEventDraft = "";
    }

    function commitEventEdit(): void {
        if (!selectedDate || editingEventIndex < 0)
            return;

        if (!editingEventDraft.trim()) {
            cancelEventEdit();
            return;
        }

        CalendarEvents.updateEvent(selectedDate, editingEventIndex, editingEventDraft);
        cancelEventEdit();
    }

    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: inner.implicitHeight + inner.anchors.margins * 2

    acceptedButtons: Qt.MiddleButton
    onClicked: root.dashState.currentDate = new Date()

    ColumnLayout {
        id: inner

        anchors.fill: parent
        anchors.margins: Tokens.padding.normal
        spacing: Tokens.spacing.small

        RowLayout {
            id: monthNavigationRow

            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            Item {
                implicitWidth: implicitHeight
                implicitHeight: prevMonthText.implicitHeight + Tokens.padding.small * 2

                StateLayer {
                    id: prevMonthStateLayer

                    radius: Tokens.rounding.full
                    onClicked: root.dashState.currentDate = new Date(root.currYear, root.currMonth - 1, 1)
                }

                MaterialIcon {
                    id: prevMonthText

                    anchors.centerIn: parent
                    text: "chevron_left"
                    color: Colours.palette.m3tertiary
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 700
                }
            }

            Item {
                Layout.fillWidth: true

                implicitWidth: monthYearDisplay.implicitWidth + Tokens.padding.small * 2
                implicitHeight: monthYearDisplay.implicitHeight + Tokens.padding.small * 2

                StateLayer {
                    onClicked: {
                        root.dashState.currentDate = new Date();
                    }

                    anchors.fill: monthYearDisplay
                    anchors.margins: -Tokens.padding.small
                    anchors.leftMargin: -Tokens.padding.normal
                    anchors.rightMargin: -Tokens.padding.normal

                    radius: Tokens.rounding.full
                    disabled: {
                        const now = new Date();
                        return root.currMonth === now.getMonth() && root.currYear === now.getFullYear();
                    }
                }

                StyledText {
                    id: monthYearDisplay

                    anchors.centerIn: parent
                    text: grid.title
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 700
                    font.capitalization: Font.Capitalize
                }
            }

            Item {
                implicitWidth: implicitHeight
                implicitHeight: nextMonthText.implicitHeight + Tokens.padding.small * 2

                StateLayer {
                    id: nextMonthStateLayer

                    onClicked: {
                        root.dashState.currentDate = new Date(root.currYear, root.currMonth + 1, 1);
                    }

                    radius: Tokens.rounding.full
                }

                MaterialIcon {
                    id: nextMonthText

                    anchors.centerIn: parent
                    text: "chevron_right"
                    color: Colours.palette.m3tertiary
                    font.pointSize: Tokens.font.size.normal
                    font.weight: 700
                }
            }
        }

        DayOfWeekRow {
            id: daysRow

            Layout.fillWidth: true
            locale: grid.locale

            delegate: StyledText {
                required property var model

                horizontalAlignment: Text.AlignHCenter
                text: model.shortName
                font.pointSize: Tokens.font.size.small
                font.weight: 700
                color: (model.day === 0 || model.day === 6) ? Colours.palette.m3secondary : Colours.palette.m3onSurfaceVariant
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: grid.implicitHeight

            MonthGrid {
                id: grid

                month: root.currMonth
                year: root.currYear

                anchors.fill: parent

                spacing: 3
                locale: Qt.locale()

                delegate: Item {
                    id: dayItem

                    required property var model
                    readonly property bool hasEvents: CalendarEvents.hasEvents(dayItem.model.date)

                    implicitWidth: implicitHeight
                    implicitHeight: text.implicitHeight + Tokens.padding.small * 2

                    StyledRect {
                        anchors.centerIn: parent
                        implicitWidth: Math.min(parent.width, parent.height)
                        implicitHeight: implicitWidth
                        radius: Tokens.rounding.full
                        color: root.sameDay(dayItem.model.date, root.selectedDate) ? Qt.alpha(Colours.palette.m3tertiary, 0.18) : "transparent"
                        border.width: dayItem.hasEvents ? 1 : 0
                        border.color: root.sameDay(dayItem.model.date, root.selectedDate) ? Qt.alpha(Colours.palette.m3tertiary, 0.55) : Qt.alpha(Colours.palette.m3primary, 0.42)
                    }

                    StyledText {
                        id: text

                        anchors.centerIn: parent

                        horizontalAlignment: Text.AlignHCenter
                        text: grid.locale.toString(dayItem.model.day)
                        color: {
                            const dayOfWeek = dayItem.model.date.getUTCDay();
                            if (dayOfWeek === 0 || dayOfWeek === 6)
                                return Colours.palette.m3secondary;

                            return Colours.palette.m3onSurfaceVariant;
                        }
                        opacity: dayItem.model.today || dayItem.model.month === grid.month ? 1 : 0.4
                        font.pointSize: Tokens.font.size.normal
                        font.weight: dayItem.model.today ? 800 : 600
                    }

                    Row {
                        id: eventDots

                        readonly property var dotColours: [Colours.palette.m3tertiary, Colours.palette.m3primary, Colours.palette.m3secondary, Colours.palette.m3error]

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        spacing: 1
                        visible: dayItem.hasEvents

                        Repeater {
                            model: CalendarEvents.listFor(dayItem.model.date).length

                            StyledRect {
                                required property int index

                                implicitWidth: 3
                                implicitHeight: 3
                                radius: Tokens.rounding.full
                                color: eventDots.dotColours[index % eventDots.dotColours.length]
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            root.hoveredDate = dayItem.model.date;
                            root.hoveredItem = dayItem;
                        }
                        onExited: {
                            if (root.hoveredItem === dayItem) {
                                root.hoveredDate = null;
                                root.hoveredItem = null;
                            }
                        }
                        onClicked: {
                            root.selectedDate = dayItem.model.date;
                            root.eventDraft = "";
                            root.cancelEventEdit();
                            root.focusPrimaryInput();
                        }
                    }
                }
            }

            StyledRect {
                id: todayIndicator

                readonly property Item todayItem: grid.contentItem.children.find(c => c.model.today) ?? null
                property Item today

                onTodayItemChanged: {
                    if (todayItem)
                        today = todayItem;
                }

                x: today ? today.x + (today.width - implicitWidth) / 2 : 0
                y: today?.y ?? 0

                implicitWidth: today?.implicitWidth ?? 0
                implicitHeight: today?.implicitHeight ?? 0

                clip: true
                radius: Tokens.rounding.full
                color: Colours.palette.m3primary

                opacity: todayItem ? 1 : 0
                scale: todayItem ? 1 : 0.7

                Colouriser {
                    x: -todayIndicator.x
                    y: -todayIndicator.y

                    implicitWidth: grid.width
                    implicitHeight: grid.height

                    source: grid
                    sourceColor: Colours.palette.m3onSurface
                    colorizationColor: Colours.palette.m3onPrimary
                }

                Behavior on opacity {
                    Anim {}
                }

                Behavior on scale {
                    Anim {}
                }

                Behavior on x {
                    Anim {
                        type: Anim.DefaultSpatial
                    }
                }

                Behavior on y {
                    Anim {
                        type: Anim.DefaultSpatial
                    }
                }
            }

            StyledRect {
                id: hoverPreview

                readonly property real targetX: root.hoveredItem ? root.hoveredItem.x + root.hoveredItem.width / 2 - width / 2 : 0
                readonly property real targetY: root.hoveredItem ? (root.hoveredItem.y > height + Tokens.spacing.small ? root.hoveredItem.y - height - Tokens.spacing.small : root.hoveredItem.y + root.hoveredItem.height + Tokens.spacing.small) : 0
                readonly property bool pointsDown: root.hoveredItem ? root.hoveredItem.y > height + Tokens.spacing.small : false
                readonly property real arrowX: root.hoveredItem ? root.hoveredItem.x + root.hoveredItem.width / 2 - x : width / 2

                z: 20
                visible: root.hoveredEvents.length > 0
                opacity: visible ? 1 : 0
                x: Math.max(0, Math.min(targetX, parent.width - width))
                y: Math.max(0, Math.min(targetY, parent.height - height))
                width: Math.min(230, parent.width)
                implicitHeight: previewColumn.implicitHeight + Tokens.padding.small * 2
                radius: Tokens.rounding.large
                color: Colours.tPalette.m3surfaceContainerHigh
                border.width: 1
                border.color: Qt.alpha(Colours.palette.m3tertiary, 0.35)

                StyledRect {
                    width: 10
                    height: 10
                    radius: 2
                    rotation: 45
                    color: hoverPreview.color
                    border.width: 1
                    border.color: hoverPreview.border.color
                    x: Math.max(Tokens.padding.normal, Math.min(parent.width - Tokens.padding.normal, hoverPreview.arrowX)) - width / 2
                    y: hoverPreview.pointsDown ? parent.height - height / 2 : -height / 2
                }

                ColumnLayout {
                    id: previewColumn

                    anchors.fill: parent
                    anchors.margins: Tokens.padding.small
                    spacing: Tokens.spacing.smaller

                    Repeater {
                        model: root.hoveredEvents

                        StyledText {
                            required property var modelData

                            Layout.fillWidth: true
                            text: modelData.title ?? modelData
                            font.pointSize: Tokens.font.size.small
                            color: Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }
                    }
                }

                Behavior on opacity {
                    Anim {}
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            visible: root.selectedDate !== null
            implicitHeight: visible ? eventEditor.implicitHeight + Tokens.padding.small * 2 : 0
            radius: Tokens.rounding.normal
            color: Colours.tPalette.m3surfaceContainer

            ColumnLayout {
                id: eventEditor

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Tokens.padding.small
                spacing: Tokens.spacing.small

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    MaterialIcon {
                        text: "event"
                        color: Colours.palette.m3tertiary
                        font.pointSize: Tokens.font.size.normal
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: root.selectedDate ? root.dayLabel(root.selectedDate) : ""
                        font.pointSize: Tokens.font.size.small
                        font.weight: 700
                        color: Colours.palette.m3onSurface
                        elide: Text.ElideRight
                    }

                    IconButton {
                        icon: "close"
                        type: IconButton.Text
                        onClicked: {
                            root.selectedDate = null;
                            root.eventDraft = "";
                            root.cancelEventEdit();
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledInputField {
                        id: eventInput

                        Layout.fillWidth: true
                        text: root.eventDraft
                        placeholderText: qsTr("Add event")
                        horizontalAlignment: TextInput.AlignLeft
                        onTextEdited: text => root.eventDraft = text
                        onEditingFinished: root.addSelectedEvent()
                    }

                    IconButton {
                        icon: "add"
                        type: IconButton.Tonal
                        onClicked: root.addSelectedEvent()
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: root.selectedEvents.length > 0
                    spacing: Tokens.spacing.smaller

                    Repeater {
                        model: root.selectedEvents

                        RowLayout {
                            required property int index
                            required property var modelData
                            readonly property bool editing: root.editingEventIndex === index
                            readonly property string eventTitleText: String(modelData.title ?? modelData ?? "")

                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            Item {
                                Layout.fillWidth: true
                                implicitHeight: editing ? eventEditInput.implicitHeight : eventTitle.implicitHeight

                                StyledText {
                                    id: eventTitle

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: !editing
                                    text: eventTitleText
                                    font.pointSize: Tokens.font.size.small
                                    color: Colours.palette.m3onSurfaceVariant
                                    elide: Text.ElideRight
                                }

                                StyledInputField {
                                    id: eventEditInput

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: editing
                                    placeholderText: qsTr("Edit event")
                                    horizontalAlignment: TextInput.AlignLeft
                                    onTextEdited: text => root.editingEventDraft = text
                                    onEditingFinished: root.commitEventEdit()

                                    function loadCurrentEvent(): void {
                                        root.editingEventDraft = eventTitleText;
                                        setTextValue(eventTitleText);
                                        Qt.callLater(() => {
                                            setTextValue(eventTitleText);
                                            focusInput();
                                        });
                                    }

                                    onVisibleChanged: if (visible)
                                        loadCurrentEvent()

                                    Component.onCompleted: if (visible)
                                        loadCurrentEvent()
                                }
                            }

                            IconButton {
                                icon: editing ? "check" : "edit"
                                type: IconButton.Text
                                onClicked: {
                                    if (editing)
                                        root.commitEventEdit();
                                    else
                                        root.startEventEdit(index, eventTitleText);
                                }
                            }

                            IconButton {
                                icon: "delete"
                                type: IconButton.Text
                                onClicked: {
                                    if (editing)
                                        root.cancelEventEdit();
                                    CalendarEvents.removeEvent(root.selectedDate, index);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
