pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services

Variants {
    model: Screens.screens

    StyledWindow {
        id: win

        required property ShellScreen modelData

        readonly property int outerMargin: 18
        readonly property bool shouldShow: !PomodoroTimer.overlayHidden && PomodoroTimer.hasActiveSession
        readonly property color accentColour: PomodoroTimer.attention ? Colours.palette.m3error : PomodoroTimer.activeTool === "stopwatch" ? Colours.palette.m3secondary : PomodoroTimer.activeTool === "timer" ? Colours.palette.m3primary : PomodoroTimer.mode === "work" ? Colours.palette.m3tertiary : Colours.palette.m3primary
        readonly property string titleText: PomodoroTimer.attention ? PomodoroTimer.attentionTitle : PomodoroTimer.activeTitle
        readonly property string detailText: PomodoroTimer.attention ? PomodoroTimer.attentionBody : PomodoroTimer.activeModeLabel

        property real cardX: outerMargin
        property real cardY: outerMargin

        function clamp(value: real, minimum: real, maximum: real): real {
            return Math.max(minimum, Math.min(value, maximum));
        }

        function boundedX(value: real): real {
            return clamp(value, outerMargin, Math.max(outerMargin, width - card.width - outerMargin));
        }

        function boundedY(value: real): real {
            return clamp(value, outerMargin, Math.max(outerMargin, height - card.height - outerMargin));
        }

        function syncPosition(): void {
            if (width <= 0 || height <= 0 || card.width <= 0 || card.height <= 0)
                return;

            const initialX = overlayPosition.x >= 0 ? overlayPosition.x : width - card.width - outerMargin;
            const initialY = overlayPosition.y >= 0 ? overlayPosition.y : height - card.height - outerMargin;

            cardX = boundedX(cardX === outerMargin && overlayPosition.x >= 0 ? initialX : cardX);
            cardY = boundedY(cardY === outerMargin && overlayPosition.y >= 0 ? initialY : cardY);

            if (overlayPosition.x < 0 || overlayPosition.y < 0) {
                cardX = boundedX(initialX);
                cardY = boundedY(initialY);
            }
        }

        function savePosition(): void {
            overlayPosition.x = cardX;
            overlayPosition.y = cardY;
        }

        screen: modelData
        name: "pomodoro-overlay"
        visible: shouldShow
        color: "transparent"
        surfaceFormat.opaque: false
        mask: Region {
            x: card.x
            y: card.y
            width: card.width
            height: card.height
        }

        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors.left: true
        anchors.top: true
        anchors.bottom: true
        anchors.right: true

        onWidthChanged: Qt.callLater(syncPosition)
        onHeightChanged: Qt.callLater(syncPosition)
        Component.onCompleted: Qt.callLater(syncPosition)

        PersistentProperties {
            id: overlayPosition

            property real x: -1
            property real y: -1

            reloadableId: "pomodoroOverlayPosition"
        }

        StyledRect {
            id: card

            x: win.cardX
            y: win.cardY

            implicitWidth: Math.max(214, layout.implicitWidth + Tokens.padding.normal * 2)
            implicitHeight: layout.implicitHeight + Tokens.padding.small * 2
            radius: Tokens.rounding.large
            color: Qt.alpha(Colours.palette.m3surfaceContainerHigh, 0.88)
            border.width: 1
            border.color: Qt.alpha(win.accentColour, PomodoroTimer.attention ? 0.95 : 0.42)
            scale: PomodoroTimer.attention ? 1.04 : 1

            onWidthChanged: Qt.callLater(win.syncPosition)
            onHeightChanged: Qt.callLater(win.syncPosition)

            Behavior on scale {
                Anim {
                    type: Anim.DefaultSpatial
                }
            }

            MouseArea {
                id: dragArea

                z: 0
                anchors.fill: parent
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                hoverEnabled: true
                preventStealing: true

                property real startX
                property real startY

                onPressed: event => {
                    startX = event.x;
                    startY = event.y;
                }

                onPositionChanged: event => {
                    if (!pressed)
                        return;

                    win.cardX = win.boundedX(win.cardX + event.x - startX);
                    win.cardY = win.boundedY(win.cardY + event.y - startY);
                }

                onReleased: win.savePosition()
            }

            ColumnLayout {
                id: layout

                z: 1
                anchors.fill: parent
                anchors.margins: Tokens.padding.small
                spacing: Tokens.spacing.small

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledRect {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: Tokens.rounding.full
                        color: Qt.alpha(win.accentColour, 0.18)

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: PomodoroTimer.attention ? "notifications_active" : PomodoroTimer.icon
                            color: win.accentColour
                            fill: 1
                            font.pointSize: Tokens.font.size.normal
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            Layout.fillWidth: true
                            text: win.titleText
                            color: Colours.palette.m3onSurface
                            font.pointSize: Tokens.font.size.small
                            font.weight: 650
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: win.detailText
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Tokens.font.size.smaller
                            elide: Text.ElideRight
                        }
                    }

                    StyledText {
                        text: PomodoroTimer.attention ? qsTr("Done") : PomodoroTimer.timeText
                        color: win.accentColour
                        font.family: Tokens.font.family.mono
                        font.pointSize: Tokens.font.size.large
                        font.weight: 800
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.smaller

                    StyledRect {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        implicitHeight: 4
                        radius: Tokens.rounding.full
                        color: Qt.rgba(1, 1, 1, 0.12)
                        clip: true

                        StyledRect {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * Math.max(0, Math.min(1, PomodoroTimer.progress))
                            radius: Tokens.rounding.full
                            color: win.accentColour

                            Behavior on width {
                                Anim {
                                    type: Anim.StandardSmall
                                }
                            }
                        }
                    }

                    IconButton {
                        icon: PomodoroTimer.attention ? "check" : PomodoroTimer.activeRunning ? "pause" : "play_arrow"
                        type: IconButton.Filled
                        padding: Tokens.padding.smaller
                        onClicked: {
                            if (PomodoroTimer.attention)
                                PomodoroTimer.attention = false;
                            else
                                PomodoroTimer.toggle();
                        }
                    }

                    IconButton {
                        icon: "replay"
                        type: IconButton.Tonal
                        padding: Tokens.padding.smaller
                        onClicked: PomodoroTimer.reset()
                    }

                    IconButton {
                        icon: "visibility_off"
                        type: IconButton.Text
                        padding: Tokens.padding.smaller
                        onClicked: PomodoroTimer.hideOverlay()
                    }
                }
            }
        }
    }
}
