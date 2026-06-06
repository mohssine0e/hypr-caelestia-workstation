pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property Repeater workspaces
    required property var occupied
    required property var visibleWorkspaceIds

    property list<var> pills: []

    function workspaceIndex(ws: int): int {
        for (let i = 0; i < workspaces.count; i++) {
            if ((workspaces.itemAt(i) as Workspace)?.ws === ws)
                return i;
        }
        return -1;
    }

    function refreshPills(): void {
        if (!occupied)
            return;

        let count = 0;
        const visible = [...visibleWorkspaceIds].filter(ws => occupied[ws]).sort((a, b) => a - b);
        for (let i = 0; i < visible.length; i++) {
            const ws = visible[i];
            const previous = visible[i - 1];
            const next = visible[i + 1];
            const startsGroup = previous !== ws - 1;
            const endsGroup = next !== ws + 1;

            if (startsGroup) {
                if (pills[count])
                    pills[count].start = ws;
                else
                    pills.push(pillComp.createObject(root, {
                        start: ws
                    }));
                count++;
            }

            if (endsGroup && pills[count - 1])
                pills[count - 1].end = ws;
        }

        if (pills.length > count)
            pills.splice(count, pills.length - count).forEach(p => p.destroy());
    }

    onOccupiedChanged: refreshPills()
    onVisibleWorkspaceIdsChanged: refreshPills()

    Repeater {
        model: ScriptModel {
            values: root.pills.filter(p => p)
        }

        StyledRect {
            id: rect

            required property var modelData

            readonly property Workspace start: root.workspaces.count > 0 ? root.workspaces.itemAt(root.workspaceIndex(modelData.start)) ?? null : null // qmllint disable incompatible-type
            readonly property Workspace end: root.workspaces.count > 0 ? root.workspaces.itemAt(root.workspaceIndex(modelData.end)) ?? null : null // qmllint disable incompatible-type

            anchors.horizontalCenter: root.horizontalCenter

            y: (start?.y ?? 0) - 1
            implicitWidth: Tokens.sizes.bar.innerWidth - Tokens.padding.small * 2 + 2
            implicitHeight: start && end ? end.y + end.size - start.y + 2 : 0

            color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
            radius: Tokens.rounding.full

            scale: 0
            Component.onCompleted: scale = 1

            Behavior on scale {
                Anim {
                    easing: Tokens.anim.standardDecel
                }
            }

            Behavior on y {
                Anim {}
            }

            Behavior on implicitHeight {
                Anim {}
            }
        }
    }

    Component {
        id: pillComp

        Pill {}
    }

    component Pill: QtObject {
        property int start
        property int end
    }
}
