pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

StyledClippingRect {
    id: root

    required property ShellScreen screen

    readonly property int activeWsId: GlobalConfig.bar.workspaces.perMonitorWorkspaces ? (Hypr.monitorFor(screen).activeWorkspace?.id ?? 1) : Hypr.activeWsId
    readonly property var windows: Hypr.toplevels.values.filter(w => w.workspace?.id === activeWsId)

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: windows.length > 0 ? appColumn.implicitHeight + Tokens.padding.small * 2 : 0
    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full
    visible: windows.length > 0

    ColumnLayout {
        id: appColumn

        anchors.centerIn: parent
        spacing: Math.floor(Tokens.spacing.small / 2)

        Repeater {
            model: ScriptModel {
                values: root.windows
            }

            delegate: Item {
                required property var modelData

                readonly property bool active: Hypr.activeToplevel?.address === modelData.address

                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Tokens.sizes.bar.innerWidth - Tokens.padding.small * 2
                implicitHeight: implicitWidth

                StyledRect {
                    anchors.fill: parent
                    radius: Tokens.rounding.full
                    color: parent.active ? Qt.alpha(Colours.palette.m3primary, 0.18) : "transparent"
                }

                StateLayer {
                    anchors.fill: parent
                    radius: Tokens.rounding.full
                    color: Colours.palette.m3onSurface
                    onClicked: Hypr.dispatch(`focuswindow address:${parent.modelData.address}`)
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    grade: 0
                    fill: parent.active ? 1 : 0
                    text: Icons.getAppCategoryIcon(parent.modelData.lastIpcObject.class, "terminal")
                    color: parent.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }

    Behavior on implicitHeight {
        Anim {}
    }
}
