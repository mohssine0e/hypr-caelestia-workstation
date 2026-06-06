pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

StyledClippingRect {
    id: root

    required property ShellScreen screen
    required property bool fullscreen

    readonly property bool onSpecial: (GlobalConfig.bar.workspaces.perMonitorWorkspaces ? Hypr.monitorFor(screen) : Hypr.focusedMonitor)?.lastIpcObject.specialWorkspace?.name !== ""
    readonly property int activeWsId: GlobalConfig.bar.workspaces.perMonitorWorkspaces ? (Hypr.monitorFor(screen).activeWorkspace?.id ?? 1) : Hypr.activeWsId
    readonly property string monitorName: Hypr.monitorFor(screen)?.name ?? ""

    readonly property var occupied: {
        const occ = {};
        for (const ws of Hypr.workspaces.values)
            occ[ws.id] = ws.lastIpcObject.windows > 0;
        return occ;
    }
    readonly property var visibleWorkspaceIds: {
        const ids = [];
        for (const ws of Hypr.workspaces.values) {
            if (ws.name.startsWith("special:"))
                continue;
            const wsMonitorName = typeof ws.monitor === "string" ? ws.monitor : ws.monitor?.name ?? "";
            if (GlobalConfig.bar.workspaces.perMonitorWorkspaces && wsMonitorName && wsMonitorName !== monitorName)
                continue;
            if (ws.id === activeWsId || ws.lastIpcObject.windows > 0)
                ids.push(ws.id);
        }
        if (!ids.includes(activeWsId))
            ids.push(activeWsId);
        return [...new Set(ids)].sort((a, b) => a - b);
    }

    function compactNumberFor(wsId: int): int {
        const idx = visibleWorkspaceIds.indexOf(wsId);
        return idx >= 0 ? idx + 1 : wsId;
    }

    property real blur: onSpecial ? 1 : 0

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: layout.implicitHeight + Tokens.padding.small * 2

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full

    Item {
        anchors.fill: parent
        scale: root.onSpecial ? 0.8 : 1
        opacity: root.onSpecial ? 0.5 : 1

        layer.enabled: root.blur > 0
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: root.blur
            blurMax: 32
        }

        Loader {
            asynchronous: true
            active: Config.bar.workspaces.occupiedBg

            anchors.fill: parent
            anchors.margins: Tokens.padding.small

            sourceComponent: OccupiedBg {
                workspaces: workspaces
                occupied: root.occupied
                visibleWorkspaceIds: root.visibleWorkspaceIds
            }
        }

        ColumnLayout {
            id: layout

            anchors.centerIn: parent
            spacing: Math.floor(Tokens.spacing.small / 2)

            Repeater {
                id: workspaces

                model: root.visibleWorkspaceIds

                Workspace {
                    required property int modelData

                    ws: modelData
                    displayNumber: root.compactNumberFor(modelData)
                    activeWsId: root.activeWsId
                    occupied: root.occupied
                }
            }
        }

        Loader {
            asynchronous: true
            anchors.horizontalCenter: parent.horizontalCenter
            active: Config.bar.workspaces.activeIndicator

            sourceComponent: ActiveIndicator {
                activeWsId: root.activeWsId
                workspaces: workspaces
                mask: layout
                fullscreen: root.fullscreen
            }
        }

        Behavior on scale {
            Anim {}
        }

        Behavior on opacity {
            Anim {}
        }
    }

    Loader {
        id: specialWs

        asynchronous: true

        anchors.fill: parent
        anchors.margins: Tokens.padding.small

        active: opacity > 0

        scale: root.onSpecial ? 1 : 0.5
        opacity: root.onSpecial ? 1 : 0

        sourceComponent: SpecialWorkspaces {
            screen: root.screen
        }

        Behavior on scale {
            Anim {}
        }

        Behavior on opacity {
            Anim {}
        }
    }

    Behavior on blur {
        Anim {
            type: Anim.StandardSmall
        }
    }
}
