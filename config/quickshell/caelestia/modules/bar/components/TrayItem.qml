pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.SystemTray
import Caelestia.Config
import qs.components.effects
import qs.services
import qs.utils
import qs.modules.bar.popouts as BarPopouts

MouseArea {
    id: root

    required property SystemTrayItem modelData
    required property int index
    required property Item bar
    required property BarPopouts.Wrapper popouts

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: Tokens.font.size.small * 2
    implicitHeight: Tokens.font.size.small * 2

    function openMenuPopout(): void {
        popouts.currentName = `traymenu${index}`;
        popouts.currentCenter = Qt.binding(() => root.mapToItem(bar, 0, root.implicitHeight / 2).y);
        popouts.hasCurrent = true;
    }

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            if (popouts.hasCurrent && popouts.currentName === `traymenu${index}`)
                popouts.hasCurrent = false;
            else
                openMenuPopout();
        } else {
            modelData.secondaryActivate();
        }
    }

    ColouredIcon {
        id: icon

        anchors.fill: parent
        source: Icons.getTrayIcon(root.modelData.id, root.modelData.icon)
        colour: Colours.palette.m3secondary
        layer.enabled: Config.bar.tray.recolour
    }
}
