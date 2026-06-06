import QtQuick
import Quickshell.Services.UPower
import qs.services

Item {
    id: root

    readonly property real lowBatteryThreshold: 0.40
    property string lastAnimationMode: ""

    function desiredProfile(): int {
        const chargingState = UPower.displayDevice.state === UPowerDeviceState.Charging
            || UPower.displayDevice.state === UPowerDeviceState.PendingCharge
            || UPower.displayDevice.state === UPowerDeviceState.FullyCharged;

        if (chargingState && PowerProfiles.hasPerformanceProfile)
            return PowerProfile.Performance;

        if (chargingState)
            return PowerProfile.Balanced;

        if (UPower.displayDevice.isLaptopBattery && UPower.displayDevice.percentage <= lowBatteryThreshold)
            return PowerProfile.PowerSaver;

        return PowerProfile.Balanced;
    }

    function syncProfile(): void {
        const target = desiredProfile();
        if (PowerProfiles.profile !== target)
            PowerProfiles.profile = target;

        syncAnimations();
    }

    function syncAnimations(): void {
        const mode = UPower.onBattery ? "battery" : "plugged";
        if (lastAnimationMode === mode)
            return;

        lastAnimationMode = mode;

        const batteryAnimations = [
            "keyword animation layersIn, 1, 7, emphasizedDecel, slide",
            "keyword animation layersOut, 1, 6, emphasizedAccel, slide",
            "keyword animation fadeLayers, 1, 7, standard",
            "keyword animation windowsIn, 1, 7, emphasizedDecel",
            "keyword animation windowsOut, 1, 6, emphasizedAccel",
            "keyword animation windowsMove, 1, 7, standard",
            "keyword animation workspaces, 1, 7, standard",
            "keyword animation specialWorkspace, 1, 6, specialWorkSwitch, slidefadevert 10%",
            "keyword animation fade, 1, 7, standard",
            "keyword animation fadeDim, 1, 7, standard",
            "keyword animation border, 1, 7, standard"
        ];

        const pluggedAnimations = [
            "keyword animation layersIn, 1, 5, emphasizedDecel, slide",
            "keyword animation layersOut, 1, 4, emphasizedAccel, slide",
            "keyword animation fadeLayers, 1, 5, standard",
            "keyword animation windowsIn, 1, 5, emphasizedDecel",
            "keyword animation windowsOut, 1, 3, emphasizedAccel",
            "keyword animation windowsMove, 1, 6, standard",
            "keyword animation workspaces, 1, 5, standard",
            "keyword animation specialWorkspace, 1, 4, specialWorkSwitch, slidefadevert 15%",
            "keyword animation fade, 1, 6, standard",
            "keyword animation fadeDim, 1, 6, standard",
            "keyword animation border, 1, 6, standard"
        ];

        Hypr.extras.batchMessage(mode === "battery" ? batteryAnimations : pluggedAnimations);
    }

    Component.onCompleted: Qt.callLater(syncProfile)

    Connections {
        target: UPower.displayDevice
        function onStateChanged(): void {
            root.syncProfile();
        }
        function onPercentageChanged(): void {
            root.syncProfile();
        }
    }

    Connections {
        target: PowerProfiles
        function onHasPerformanceProfileChanged(): void {
            root.syncProfile();
        }
    }

    Connections {
        target: UPower
        function onOnBatteryChanged(): void {
            root.syncProfile();
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.syncProfile()
    }
}
