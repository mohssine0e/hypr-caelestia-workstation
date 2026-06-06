import QtQuick
import qs.components

ListView {
    id: root

    property real wheelBoost: 1.9

    maximumFlickVelocity: 5200
    flickDeceleration: 2200

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton

        onWheel: wheel => {
            const maxY = Math.max(0, root.contentHeight - root.height);
            if (maxY <= 0)
                return;

            const rawDelta = wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : wheel.angleDelta.y / 3;
            if (rawDelta === 0)
                return;

            root.contentY = Math.max(0, Math.min(maxY, root.contentY - rawDelta * root.wheelBoost));
            wheel.accepted = true;
        }
    }

    rebound: Transition {
        Anim {
            properties: "x,y"
        }
    }
}
