pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

ColumnLayout {
    id: root

    required property int ws
    required property int displayNumber
    required property int activeWsId
    required property var occupied

    readonly property bool isWorkspace: true // Flag for finding workspace children
    // Unanimated prop for others to use as reference
    readonly property int size: implicitHeight

    readonly property bool isOccupied: occupied[ws] ?? false

    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: size

    spacing: 0

    StyledText {
        id: indicator

        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.preferredHeight: Tokens.sizes.bar.innerWidth - Tokens.padding.small * 2

        animate: true
        text: root.displayNumber.toString()
        color: Config.bar.workspaces.occupiedBg || root.isOccupied || root.activeWsId === root.ws ? Colours.palette.m3onSurface : Colours.layer(Colours.palette.m3outlineVariant, 2)
        verticalAlignment: Qt.AlignVCenter

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (Hypr.activeWsId !== root.ws)
                    Hypr.dispatch(`workspace ${root.ws}`);
                else
                    Hypr.dispatch("togglespecialworkspace special");
            }
        }
    }

    Behavior on Layout.preferredHeight {
        Anim {}
    }
}
