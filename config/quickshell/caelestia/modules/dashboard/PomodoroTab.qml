pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    property string focusMode: PomodoroTimer.activeTool === "stopwatch" ? "stopwatch" : PomodoroTimer.activeTool === "timer" ? "timer" : "pomodoro"
    property string timerTitleDraft: PomodoroTimer.timerTitle
    property string timerDurationDraft: PomodoroTimer.formatSeconds(PomodoroTimer.timerDuration)
    property var timerTitleInputRef: null

    readonly property bool needsKeyboard: focusMode === "timer"
    readonly property color accentColour: focusMode === "stopwatch" ? Colours.palette.m3secondary : focusMode === "timer" ? Colours.palette.m3primary : PomodoroTimer.mode === "work" ? Colours.palette.m3tertiary : Colours.palette.m3primary
    readonly property bool modeRunning: focusMode === "stopwatch" ? PomodoroTimer.stopwatchRunning : focusMode === "timer" ? PomodoroTimer.timerRunning : PomodoroTimer.running
    readonly property string modeTitle: focusMode === "stopwatch" ? qsTr("Stopwatch") : focusMode === "timer" ? (PomodoroTimer.timerTitle || qsTr("Timer")) : (PomodoroTimer.focusTitle || PomodoroTimer.label)
    readonly property string modeSubtitle: {
        if (focusMode === "stopwatch")
            return PomodoroTimer.stopwatchRunning ? qsTr("Tracking elapsed time") : PomodoroTimer.stopwatchDisplayMs > 0 ? qsTr("Paused") : qsTr("Open-ended session");
        if (focusMode === "timer")
            return PomodoroTimer.timerRunning ? qsTr("Counting down") : qsTr("Custom countdown");
        if (PomodoroTimer.mode === "work")
            return PomodoroTimer.running ? qsTr("Deep work is running") : qsTr("Ready for a focus block");
        return PomodoroTimer.running ? qsTr("Break is running") : qsTr("Pause before the next block");
    }
    readonly property string modeIcon: focusMode === "stopwatch" ? "timer" : focusMode === "timer" ? "hourglass_top" : PomodoroTimer.mode === "work" ? "timer" : PomodoroTimer.mode === "longBreak" ? "self_improvement" : "coffee"
    readonly property string modeTime: {
        if (focusMode === "stopwatch")
            return PomodoroTimer.stopwatchTimeText;
        if (focusMode === "timer")
            return PomodoroTimer.activeTool === "timer" ? PomodoroTimer.timeText : PomodoroTimer.formatSeconds(PomodoroTimer.timerRemaining);
        return PomodoroTimer.activeTool === "pomodoro" ? PomodoroTimer.timeText : PomodoroTimer.formatSeconds(PomodoroTimer.remaining);
    }
    readonly property real modeProgress: {
        if (focusMode === "stopwatch")
            return PomodoroTimer.stopwatchDisplayMs > 0 ? 1 : 0;
        if (focusMode === "timer")
            return PomodoroTimer.activeTool === "timer" ? PomodoroTimer.progress : (PomodoroTimer.timerDuration > 0 ? 1 - PomodoroTimer.timerRemaining / PomodoroTimer.timerDuration : 0);
        return PomodoroTimer.activeTool === "pomodoro" ? PomodoroTimer.progress : (PomodoroTimer.total > 0 ? 1 - PomodoroTimer.remaining / PomodoroTimer.total : 0);
    }
    readonly property string nextPomodoroPhase: {
        if (PomodoroTimer.mode === "work")
            return PomodoroTimer.focusRounds % PomodoroTimer.longBreakEvery === PomodoroTimer.longBreakEvery - 1 ? qsTr("long break") : qsTr("short break");
        return qsTr("focus");
    }
    readonly property string stateLabel: {
        if (focusMode === "stopwatch")
            return PomodoroTimer.stopwatchRunning ? qsTr("Stopwatch running") : PomodoroTimer.stopwatchDisplayMs > 0 ? qsTr("Stopwatch paused") : qsTr("Stopwatch ready");
        if (focusMode === "timer")
            return PomodoroTimer.timerRunning ? qsTr("Timer running") : PomodoroTimer.timerRemaining !== PomodoroTimer.timerDuration ? qsTr("Timer paused") : qsTr("Timer ready");
        if (PomodoroTimer.running)
            return PomodoroTimer.mode === "work" ? qsTr("Focus running") : qsTr("Break running");
        return PomodoroTimer.mode === "work" ? qsTr("Focus ready") : qsTr("Break ready");
    }
    readonly property string primaryLabel: {
        if (modeRunning)
            return qsTr("Pause");
        if (focusMode === "stopwatch" && PomodoroTimer.stopwatchDisplayMs > 0)
            return qsTr("Resume");
        if (focusMode === "timer" && PomodoroTimer.timerRemaining !== PomodoroTimer.timerDuration)
            return qsTr("Resume");
        return qsTr("Start");
    }

    function focusPrimaryInput(): void {
        if (focusMode === "timer")
            Qt.callLater(() => timerTitleInputRef?.focusInput());
    }

    function startTimerFromDraft(): void {
        if (PomodoroTimer.startTimerFromInput(timerTitleDraft, timerDurationDraft))
            focusMode = "timer";
    }

    function setTimerPreset(minutes: int): void {
        timerDurationDraft = PomodoroTimer.formatSeconds(minutes * 60);
        PomodoroTimer.configureTimer(timerTitleDraft, minutes * 60);
        focusMode = "timer";
    }

    function primaryAction(): void {
        if (focusMode === "stopwatch") {
            PomodoroTimer.toggleStopwatch();
            return;
        }

        if (focusMode === "timer") {
            if (PomodoroTimer.activeTool !== "timer" || PomodoroTimer.timerRemaining === PomodoroTimer.timerDuration)
                startTimerFromDraft();
            else
                PomodoroTimer.toggleTimer();
            return;
        }

        PomodoroTimer.togglePomodoro();
    }

    function resetCurrent(): void {
        if (focusMode === "stopwatch")
            PomodoroTimer.resetStopwatch();
        else if (focusMode === "timer")
            PomodoroTimer.resetTimer();
        else
            PomodoroTimer.resetPomodoro();
    }

    implicitWidth: 620
    implicitHeight: 344

    StyledRect {
        anchors.fill: parent
        radius: Tokens.rounding.large
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: Tokens.spacing.small

                Item {
                    Layout.fillWidth: true
                }

                ModeChip {
                    icon: "timer"
                    label: qsTr("Pomodoro")
                    active: root.focusMode === "pomodoro"
                    onClicked: root.focusMode = "pomodoro"
                }

                ModeChip {
                    icon: "hourglass_top"
                    label: qsTr("Timer")
                    active: root.focusMode === "timer"
                    onClicked: {
                        root.focusMode = "timer";
                        root.focusPrimaryInput();
                    }
                }

                ModeChip {
                    icon: "timer"
                    label: qsTr("Stopwatch")
                    active: root.focusMode === "stopwatch"
                    onClicked: root.focusMode = "stopwatch"
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            StyledRect {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)
                radius: Tokens.rounding.large
                border.width: 1
                border.color: Qt.alpha(root.accentColour, 0.20)

                Loader {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.normal
                    sourceComponent: root.focusMode === "stopwatch" ? stopwatchBody : focusBody
                }
            }
        }
    }

    Component {
        id: focusBody

        ColumnLayout {
            spacing: Tokens.spacing.small

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                spacing: Tokens.spacing.small

                Item {
                    Layout.fillHeight: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 420
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Tokens.spacing.smaller

                    StyledText {
                        Layout.fillWidth: true
                        text: root.modeTitle
                        color: Colours.palette.m3onSurface
                        font.pointSize: Tokens.font.size.small
                        font.weight: 600
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: root.modeTime
                        color: root.accentColour
                        font.family: Tokens.font.family.mono
                        font.pointSize: Tokens.font.size.extraLarge * 2.05
                        font.weight: 760
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                StyledRect {
                    id: progressTrack

                    Layout.fillWidth: true
                    Layout.maximumWidth: 430
                    Layout.alignment: Qt.AlignHCenter
                    implicitHeight: 7
                    radius: Tokens.rounding.full
                    color: Qt.alpha(root.accentColour, 0.14)
                    clip: true

                    StyledRect {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * Math.max(0, Math.min(1, root.modeProgress))
                        radius: Tokens.rounding.full
                        color: root.accentColour

                        Behavior on width {
                            Anim {
                                type: Anim.StandardSmall
                            }
                        }
                    }
                }

                Loader {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 470
                    Layout.alignment: Qt.AlignHCenter
                    sourceComponent: root.focusMode === "timer" ? timerOptions : pomodoroOptions
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Tokens.spacing.small

                    TextButton {
                        text: root.primaryLabel
                        type: TextButton.Filled
                        horizontalPadding: Tokens.padding.large
                        onClicked: root.primaryAction()
                    }

                    IconButton {
                        icon: "add"
                        type: IconButton.Tonal
                        onClicked: root.focusMode === "timer" ? PomodoroTimer.addTimerMinutes(5) : PomodoroTimer.addMinutes(5)
                    }

                    IconButton {
                        visible: root.focusMode === "pomodoro"
                        icon: "skip_next"
                        type: IconButton.Text
                        onClicked: PomodoroTimer.skip()
                    }

                    TextButton {
                        visible: PomodoroTimer.overlayHidden && PomodoroTimer.hasActiveSession
                        text: qsTr("Show")
                        type: TextButton.Tonal
                        onClicked: PomodoroTimer.showOverlay()
                    }

                    IconButton {
                        icon: "replay"
                        type: IconButton.Text
                        padding: Tokens.padding.small / 2
                        onClicked: root.resetCurrent()
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    Component {
        id: stopwatchBody

        ColumnLayout {
            spacing: Tokens.spacing.small

            Item {
                Layout.fillHeight: true
            }

            StyledText {
                Layout.fillWidth: true
                text: root.modeTime
                color: root.accentColour
                font.family: Tokens.font.family.mono
                font.pointSize: Tokens.font.size.extraLarge * 2.15
                font.weight: 760
                horizontalAlignment: Text.AlignHCenter
            }

            StyledText {
                Layout.fillWidth: true
                text: root.modeSubtitle
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.small
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Tokens.spacing.small

                TextButton {
                    text: root.primaryLabel
                    type: TextButton.Filled
                    horizontalPadding: Tokens.padding.large
                    onClicked: root.primaryAction()
                }

                IconButton {
                    icon: "replay"
                    type: IconButton.Tonal
                    onClicked: root.resetCurrent()
                }

                TextButton {
                    visible: PomodoroTimer.overlayHidden && PomodoroTimer.hasActiveSession
                    text: qsTr("Show")
                    type: TextButton.Tonal
                    onClicked: PomodoroTimer.showOverlay()
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    Component {
        id: pomodoroOptions

        ColumnLayout {
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Tokens.spacing.small

                PhaseChip {
                    label: qsTr("Focus")
                    active: PomodoroTimer.mode === "work"
                    onClicked: PomodoroTimer.setMode("work")
                }

                PhaseChip {
                    label: qsTr("Break")
                    active: PomodoroTimer.mode === "shortBreak"
                    onClicked: PomodoroTimer.setMode("shortBreak")
                }

                PhaseChip {
                    label: qsTr("Long")
                    active: PomodoroTimer.mode === "longBreak"
                    onClicked: PomodoroTimer.setMode("longBreak")
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                StyledText {
                    text: qsTr("%1 rounds done. Next: %2.").arg(PomodoroTimer.focusRounds).arg(root.nextPomodoroPhase)
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Component {
        id: timerOptions

        ColumnLayout {
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StyledInputField {
                    id: timerTitleInput

                    Layout.fillWidth: true
                    text: root.timerTitleDraft
                    placeholderText: qsTr("Label")
                    horizontalAlignment: TextInput.AlignLeft
                    Component.onCompleted: root.timerTitleInputRef = timerTitleInput
                    Component.onDestruction: {
                        if (root.timerTitleInputRef === timerTitleInput)
                            root.timerTitleInputRef = null;
                    }
                    onTextEdited: text => root.timerTitleDraft = text
                }

                StyledInputField {
                    Layout.preferredWidth: 112
                    text: root.timerDurationDraft
                    placeholderText: qsTr("25:00")
                    horizontalAlignment: TextInput.AlignHCenter
                    onTextEdited: text => root.timerDurationDraft = text
                    onEditingFinished: root.startTimerFromDraft()
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Tokens.spacing.small

                PhaseChip {
                    label: qsTr("+1")
                    onClicked: PomodoroTimer.addTimerMinutes(1)
                }

                PhaseChip {
                    label: qsTr("+5")
                    onClicked: PomodoroTimer.addTimerMinutes(5)
                }

                PresetChip {
                    label: qsTr("15")
                    onClicked: root.setTimerPreset(15)
                }

                PresetChip {
                    label: qsTr("25")
                    onClicked: root.setTimerPreset(25)
                }

                PresetChip {
                    label: qsTr("45")
                    onClicked: root.setTimerPreset(45)
                }

                PresetChip {
                    label: qsTr("90")
                    onClicked: root.setTimerPreset(90)
                }
            }
        }
    }

    component ModeChip: StyledRect {
        id: chip

        required property string icon
        required property string label
        required property bool active
        signal clicked

        implicitWidth: row.implicitWidth + Tokens.padding.normal * 2
        implicitHeight: 34
        radius: Tokens.rounding.full
        color: active ? root.accentColour : Qt.alpha(Colours.palette.m3surfaceContainerHigh, 0.72)
        border.width: active ? 0 : 1
        border.color: Qt.alpha(Colours.palette.m3outline, 0.10)

        StateLayer {
            radius: parent.radius
            color: active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
            onClicked: chip.clicked()
        }

        RowLayout {
            id: row

            anchors.centerIn: parent
            spacing: Tokens.spacing.smaller

            MaterialIcon {
                text: chip.icon
                color: chip.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                fill: chip.active ? 1 : 0
                font.pointSize: Tokens.font.size.normal
            }

            StyledText {
                text: chip.label
                color: chip.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.small
                font.weight: chip.active ? 700 : 500
            }
        }
    }

    component PhaseChip: StyledRect {
        id: phase

        required property string label
        property bool active: false
        signal clicked

        implicitWidth: text.implicitWidth + Tokens.padding.normal * 2
        implicitHeight: 30
        radius: Tokens.rounding.full
        color: active ? Qt.alpha(root.accentColour, 0.24) : Qt.alpha(Colours.palette.m3surfaceContainerHigh, 0.55)
        border.width: active ? 1 : 0
        border.color: Qt.alpha(root.accentColour, 0.42)

        StateLayer {
            radius: parent.radius
            color: active ? root.accentColour : Colours.palette.m3onSurface
            onClicked: phase.clicked()
        }

        StyledText {
            id: text

            anchors.centerIn: parent
            text: phase.label
            color: active ? root.accentColour : Colours.palette.m3onSurfaceVariant
            font.pointSize: Tokens.font.size.small
            font.weight: active ? 700 : 500
        }
    }

    component PresetChip: PhaseChip {
        implicitHeight: 28
        color: Qt.alpha(root.accentColour, 0.10)
        border.width: 1
        border.color: Qt.alpha(root.accentColour, 0.18)
    }
}
