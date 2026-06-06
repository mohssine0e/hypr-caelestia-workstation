pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

RowLayout {
    id: root

    required property PopoutState popouts

    spacing: Tokens.spacing.small

    function runAction(command: var): void {
        popouts.hasCurrent = false;
        Quickshell.execDetached(command);
    }

    PowerAction {
        icon: Config.session.icons.logout
        label: qsTr("Logout")
        command: Config.session.commands.logout
    }

    PowerAction {
        icon: Config.session.icons.hibernate
        label: qsTr("Sleep")
        command: Config.session.commands.hibernate
    }

    PowerAction {
        icon: Config.session.icons.reboot
        label: qsTr("Restart")
        command: Config.session.commands.reboot
    }

    PowerAction {
        icon: Config.session.icons.shutdown
        label: qsTr("Off")
        command: Config.session.commands.shutdown
        danger: true
    }

    component PowerAction: StyledRect {
        id: action

        required property string icon
        required property string label
        required property list<string> command
        property bool danger: false

        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 58
        implicitHeight: 54
        radius: Tokens.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        StateLayer {
            radius: parent.radius
            color: action.danger ? Colours.palette.m3error : Colours.palette.m3onSurface
            onClicked: root.runAction(action.command)
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 1

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: action.icon
                color: action.danger ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.large
                fill: 0
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: action.label
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.smaller
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }
}
