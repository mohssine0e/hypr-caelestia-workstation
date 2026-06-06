pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    id: root

    width: 260
    spacing: Tokens.spacing.normal

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.normal

        StyledRect {
            implicitWidth: 44
            implicitHeight: 44
            radius: Tokens.rounding.full
            color: Qt.alpha(Colours.palette.m3primary, 0.16)

            MaterialIcon {
                anchors.centerIn: parent
                text: PomodoroTimer.icon
                color: Colours.palette.m3primary
                font.pointSize: Tokens.font.size.large
                fill: 1
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                text: PomodoroTimer.label
                color: Colours.palette.m3onSurface
                font.weight: 600
            }

            StyledText {
                text: PomodoroTimer.running ? qsTr("Running") : qsTr("Paused")
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.small
            }
        }

        StyledText {
            text: PomodoroTimer.timeText
            color: Colours.palette.m3primary
            font.family: Tokens.font.family.mono
            font.pointSize: Tokens.font.size.large
            font.weight: 700
        }
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: 8
        radius: Tokens.rounding.full
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
        clip: true

        StyledRect {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * PomodoroTimer.progress
            radius: Tokens.rounding.full
            color: PomodoroTimer.mode === "work" ? Colours.palette.m3primary : Colours.palette.m3tertiary

            Behavior on width {
                Anim {
                    type: Anim.StandardSmall
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        ModeButton {
            label: qsTr("Focus")
            active: PomodoroTimer.mode === "work"
            onClicked: PomodoroTimer.setMode("work")
        }

        ModeButton {
            label: qsTr("Break")
            active: PomodoroTimer.mode === "shortBreak"
            onClicked: PomodoroTimer.setMode("shortBreak")
        }

        ModeButton {
            label: qsTr("Long")
            active: PomodoroTimer.mode === "longBreak"
            onClicked: PomodoroTimer.setMode("longBreak")
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Tokens.spacing.small

        IconButton {
            icon: PomodoroTimer.running ? "pause" : "play_arrow"
            onClicked: PomodoroTimer.toggle()
        }

        TextButton {
            text: qsTr("+5")
            type: TextButton.Tonal
            onClicked: PomodoroTimer.addMinutes(5)
        }

        IconButton {
            visible: PomodoroTimer.overlayHidden && (PomodoroTimer.running || PomodoroTimer.remaining !== PomodoroTimer.total)
            icon: "visibility"
            type: IconButton.Tonal
            onClicked: PomodoroTimer.showOverlay()
        }

        IconButton {
            icon: "replay"
            type: IconButton.Tonal
            onClicked: PomodoroTimer.reset()
        }

        IconButton {
            icon: "skip_next"
            type: IconButton.Text
            onClicked: PomodoroTimer.skip()
        }
    }

    StyledText {
        Layout.fillWidth: true
        text: qsTr("%1 focus rounds done. Long break every %2.").arg(PomodoroTimer.focusRounds).arg(PomodoroTimer.longBreakEvery)
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Tokens.font.size.small
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    TextButton {
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("Reset rounds")
        type: TextButton.Text
        onClicked: PomodoroTimer.resetRounds()
    }

    component ModeButton: StyledRect {
        id: modeButton

        required property string label
        required property bool active
        signal clicked

        Layout.fillWidth: true
        implicitHeight: modeLabel.implicitHeight + Tokens.padding.smaller * 2
        radius: Tokens.rounding.full
        color: active ? Colours.palette.m3primary : Colours.tPalette.m3surfaceContainer

        StateLayer {
            radius: parent.radius
            color: active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
            onClicked: modeButton.clicked()
        }

        StyledText {
            id: modeLabel

            anchors.centerIn: parent
            text: modeButton.label
            color: modeButton.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
            font.pointSize: Tokens.font.size.small
            font.weight: modeButton.active ? 700 : 500
        }

        Behavior on color {
            CAnim {}
        }
    }
}
