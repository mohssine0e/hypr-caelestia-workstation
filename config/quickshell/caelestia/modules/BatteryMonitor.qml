import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Caelestia
import Caelestia.Config

Scope {
    id: root

    readonly property list<var> warnLevels: [...GlobalConfig.general.battery.warnLevels].sort((a, b) => b.level - a.level)
    readonly property int safeWarnLevel: 15
    readonly property int safeCriticalLevel: 10
    readonly property int safeActionLevel: 7
    property bool safeWarned: false
    property bool safeCriticalWarned: false

    Connections {
        function onOnBatteryChanged(): void {
            if (UPower.onBattery) {
                if (GlobalConfig.utilities.toasts.chargingChanged)
                    Toaster.toast(qsTr("Charger unplugged"), qsTr("Battery is discharging"), "power_off");
            } else {
                if (GlobalConfig.utilities.toasts.chargingChanged)
                    Toaster.toast(qsTr("Charger plugged in"), qsTr("Battery is charging"), "power");
                for (const level of root.warnLevels)
                    level.warned = false;
                root.safeWarned = false;
                root.safeCriticalWarned = false;
                hibernateTimer.stop();
            }
        }

        target: UPower
    }

    Connections {
        function onPercentageChanged(): void {
            if (!UPower.onBattery)
                return;

            const p = UPower.displayDevice.percentage * 100;
            if (p <= root.safeWarnLevel && !root.safeWarned) {
                root.safeWarned = true;
                Toaster.toast(qsTr("Battery low"), qsTr("Plug in soon. Power saver is active."), "battery_android_alert", Toast.Warning);
            }
            if (p <= root.safeCriticalLevel && !root.safeCriticalWarned) {
                root.safeCriticalWarned = true;
                Toaster.toast(qsTr("Battery critical"), qsTr("Plug in now. Sleep protection starts at %1%.").arg(root.safeActionLevel), "battery_android_alert", Toast.Error);
            }

            for (const level of root.warnLevels) {
                if (p <= level.level && !level.warned) {
                    level.warned = true;
                    Toaster.toast(level.title ?? qsTr("Battery warning"), level.message ?? qsTr("Battery level is low"), level.icon ?? "battery_android_alert", level.critical ? Toast.Error : Toast.Warning);
                }
            }

            if (!hibernateTimer.running && p <= root.safeActionLevel) {
                Toaster.toast(qsTr("Suspending in 5 seconds"), qsTr("Plug in before waking to avoid data loss"), "battery_android_alert", Toast.Error);
                hibernateTimer.start();
            }
        }

        target: UPower.displayDevice
    }

    Timer {
        id: hibernateTimer

        interval: 5000
        onTriggered: Quickshell.execDetached(["systemctl", "suspend"])
    }
}
