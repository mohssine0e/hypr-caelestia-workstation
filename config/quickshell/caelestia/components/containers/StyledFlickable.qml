import QtQuick
import qs.components

Flickable {
    id: root

    property real wheelBoost: 1.9

    maximumFlickVelocity: 5200
    flickDeceleration: 2200

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton

        onWheel: wheel => {
            const verticalScrollable = root.contentHeight > root.height;
            const horizontalScrollable = root.contentWidth > root.width;
            const horizontalIntent = Math.abs(wheel.pixelDelta.x || wheel.angleDelta.x) > Math.abs(wheel.pixelDelta.y || wheel.angleDelta.y);

            if (horizontalScrollable && horizontalIntent) {
                const maxX = Math.max(0, root.contentWidth - root.width);
                const rawX = wheel.pixelDelta.x !== 0 ? wheel.pixelDelta.x : wheel.angleDelta.x / 3;
                if (rawX !== 0) {
                    root.contentX = Math.max(0, Math.min(maxX, root.contentX - rawX * root.wheelBoost));
                    wheel.accepted = true;
                }
                return;
            }

            if (!verticalScrollable)
                return;

            const maxY = Math.max(0, root.contentHeight - root.height);
            const rawY = wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : wheel.angleDelta.y / 3;
            if (rawY === 0)
                return;

            root.contentY = Math.max(0, Math.min(maxY, root.contentY - rawY * root.wheelBoost));
            wheel.accepted = true;
        }
    }

    rebound: Transition {
        Anim {
            properties: "x,y"
        }
    }
}
