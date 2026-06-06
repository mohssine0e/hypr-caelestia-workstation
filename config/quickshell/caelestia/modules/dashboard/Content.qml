pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.filedialog

Item {
    id: root

    required property DrawerVisibilities visibilities
    readonly property bool needsKeyboard: view.currentItem?.item?.needsKeyboard ?? false
    required property DashboardState dashState
    required property FileDialog facePicker

    function focusCurrentInput(): void {
        const current = view.currentItem?.item;
        if (current?.needsKeyboard && typeof current.focusPrimaryInput === "function")
            Qt.callLater(() => current.focusPrimaryInput());
    }

    readonly property var dashboardTabs: {
        const allTabs = [
            {
                component: dashComponent,
                iconName: "dashboard",
                text: qsTr("Dashboard"),
                enabled: Config.dashboard.showDashboard
            },
            {
                component: mediaComponent,
                iconName: "queue_music",
                text: qsTr("Media"),
                enabled: Config.dashboard.showMedia
            },
            {
                component: performanceComponent,
                iconName: "monitoring",
                text: qsTr("Performance"),
                enabled: true
            },
            {
                component: pomodoroComponent,
                iconName: "timer",
                text: qsTr("Timebox"),
                enabled: true
            },
            {
                component: todoComponent,
                iconName: "checklist",
                text: qsTr("Todos"),
                enabled: true
            }
        ];
        return allTabs.filter(tab => tab.enabled);
    }

    readonly property real nonAnimWidth: view.implicitWidth + viewWrapper.anchors.margins * 2
    readonly property real nonAnimHeight: tabs.implicitHeight + tabs.anchors.topMargin + view.implicitHeight + viewWrapper.anchors.margins * 2

    implicitWidth: nonAnimWidth
    implicitHeight: nonAnimHeight
    focus: visibilities.dashboard

    function cycleTab(backwards: bool): void {
        const count = root.dashboardTabs.length;
        if (count <= 0)
            return;

        const current = Math.min(root.dashState.currentTab, count - 1);
        root.dashState.currentTab = (current + (backwards ? -1 : 1) + count) % count;
        Qt.callLater(() => root.forceActiveFocus());
    }

    Keys.priority: Keys.BeforeItem
    Keys.onPressed: event => {
        if (!root.visibilities.dashboard)
            return;

        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            root.cycleTab(event.key === Qt.Key_Backtab || (event.modifiers & Qt.ShiftModifier));
            event.accepted = true;
        }
    }

    Shortcut {
        enabled: root.visibilities.dashboard
        sequence: "Tab"
        context: Qt.WindowShortcut
        onActivated: root.cycleTab(false)
    }

    Shortcut {
        enabled: root.visibilities.dashboard
        sequences: ["Shift+Tab", "Backtab", "Shift+Backtab"]
        context: Qt.WindowShortcut
        onActivated: root.cycleTab(true)
    }

    Tabs {
        id: tabs

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Tokens.padding.normal
        anchors.margins: Tokens.padding.large

        nonAnimWidth: root.nonAnimWidth - anchors.margins * 2
        dashState: root.dashState
        tabs: root.dashboardTabs
    }

    ClippingRectangle {
        id: viewWrapper

        anchors.top: tabs.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.padding.large

        radius: Tokens.rounding.normal
        color: "transparent"

        Flickable {
            id: view

            readonly property int currentIndex: Math.min(root.dashState.currentTab, Math.max(0, root.dashboardTabs.length - 1))
            readonly property Item currentItem: {
                repeater.count; // Trigger update on count change
                return repeater.itemAt(currentIndex);
            }

            anchors.fill: parent

            flickableDirection: Flickable.HorizontalFlick

            implicitWidth: currentItem?.implicitWidth ?? 0
            implicitHeight: currentItem?.implicitHeight ?? 0

            contentX: currentItem?.x ?? 0
            contentWidth: row.implicitWidth
            contentHeight: row.implicitHeight

            onContentXChanged: {
                if (!moving || !currentItem)
                    return;

                const x = contentX - currentItem.x;
                if (x > currentItem.implicitWidth / 2)
                    root.dashState.currentTab = Math.min(root.dashState.currentTab + 1, tabs.count - 1);
                else if (x < -currentItem.implicitWidth / 2)
                    root.dashState.currentTab = Math.max(root.dashState.currentTab - 1, 0);
            }

            onDragEnded: {
                if (!currentItem)
                    return;

                const x = contentX - currentItem.x;
                if (x > currentItem.implicitWidth / 10)
                    root.dashState.currentTab = Math.min(root.dashState.currentTab + 1, tabs.count - 1);
                else if (x < -currentItem.implicitWidth / 10)
                    root.dashState.currentTab = Math.max(root.dashState.currentTab - 1, 0);
                else
                    contentX = Qt.binding(() => currentItem?.x ?? 0);
            }

            onCurrentIndexChanged: root.forceActiveFocus()

            RowLayout {
                id: row

                Repeater {
                    id: repeater

                    model: ScriptModel {
                        values: root.dashboardTabs
                    }

                    delegate: Loader {
                        id: paneLoader

                        required property int index
                        required property var modelData

                        Layout.alignment: Qt.AlignTop

                        sourceComponent: modelData.component

                        Component.onCompleted: active = Qt.binding(() => {
                            if (index === view.currentIndex)
                                return true;
                            const vx = Math.floor(view.visibleArea.xPosition * view.contentWidth);
                            const vex = Math.floor(vx + view.visibleArea.widthRatio * view.contentWidth);
                            return (vx >= x && vx <= x + implicitWidth) || (vex >= x && vex <= x + implicitWidth);
                        })
                    }
                }
            }

            Component {
                id: dashComponent

                Dash {
                    visibilities: root.visibilities
                    dashState: root.dashState
                    facePicker: root.facePicker
                }
            }

            Component {
                id: mediaComponent

                MediaWrapper {
                    visibilities: root.visibilities
                }
            }

            Component {
                id: performanceComponent

                Performance {}
            }

            Component {
                id: pomodoroComponent

                PomodoroTab {}
            }

            Component {
                id: todoComponent

                TodoTab {}
            }

            Behavior on contentX {
                Anim {}
            }
        }
    }

    Connections {
        target: root.visibilities

        function onDashboardChanged(): void {
            if (root.visibilities.dashboard)
                root.forceActiveFocus();
        }
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.EmphasizedLarge
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: Anim.EmphasizedLarge
        }
    }
}
