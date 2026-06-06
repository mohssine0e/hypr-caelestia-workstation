pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    readonly property var mainDisk: SystemUsage.disks.length > 0 ? SystemUsage.disks[0] : null
    readonly property color cpuColour: Colours.palette.m3primary
    readonly property color memoryColour: Colours.palette.m3tertiary
    readonly property color diskColour: Colours.palette.m3secondary

    implicitWidth: 720
    implicitHeight: 350

    function clamp01(value: real): real {
        return Math.max(0, Math.min(1, Number(value) || 0));
    }

    function percent(value: real): string {
        return `${Math.round(clamp01(value) * 100)}%`;
    }

    function formatKib(kib: real): string {
        const out = SystemUsage.formatKib(Number(kib) || 0);
        const value = Number(out.value) || 0;
        return `${value >= 10 ? value.toFixed(0) : value.toFixed(1)} ${out.unit}`;
    }

    function formatBytes(bytes: real): string {
        const kib = (Number(bytes) || 0) / 1024;
        return formatKib(kib).replace("KiB", "KB").replace("MiB", "MB").replace("GiB", "GB").replace("TiB", "TB");
    }

    function rateText(bytesPerSecond: real): string {
        return `${formatBytes(bytesPerSecond)}/s`;
    }

    function tempText(value: real): string {
        return value > 0 ? `${Math.round(value)}°C` : "--";
    }

    function frequencyText(value: real): string {
        return value > 0 ? `${(value / 1000).toFixed(2)} GHz` : "--";
    }

    function thermalAccent(value: real): color {
        if (value <= 0)
            return Colours.palette.m3onSurfaceVariant;
        if (value < 55)
            return Colours.palette.m3tertiary;
        if (value < 75)
            return Colours.palette.m3primary;
        return Colours.palette.m3error;
    }

    function powerProfileText(): string {
        const profile = PowerProfiles.profile;
        if (profile === PowerProfile.PowerSaver)
            return qsTr("Power saver");
        if (profile === PowerProfile.Performance)
            return qsTr("Performance");
        return qsTr("Balanced");
    }

    function powerProfileIcon(): string {
        const profile = PowerProfiles.profile;
        if (profile === PowerProfile.PowerSaver)
            return "energy_savings_leaf";
        if (profile === PowerProfile.Performance)
            return "rocket_launch";
        return "balance";
    }

    function batteryText(): string {
        return UPower.displayDevice.isLaptopBattery ? `${Math.round(UPower.displayDevice.percentage * 100)}%` : qsTr("No battery");
    }

    function batteryStatusText(): string {
        if (!UPower.displayDevice.isLaptopBattery)
            return root.powerProfileText();
        if (UPower.onBattery)
            return qsTr("On battery");
        if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
            return qsTr("Fully charged");
        return qsTr("Charging");
    }

    function formatSeconds(seconds: real): string {
        const s = Math.max(0, Math.floor(Number(seconds) || 0));
        const hours = Math.floor(s / 3600);
        const minutes = Math.floor((s % 3600) / 60);
        if (hours > 0)
            return qsTr("%1h %2m").arg(hours).arg(minutes.toString().padStart(2, "0"));
        if (minutes > 0)
            return qsTr("%1m").arg(minutes);
        return "--";
    }

    function batteryTimeText(): string {
        if (!UPower.displayDevice.isLaptopBattery)
            return "--";
        if (UPower.onBattery)
            return formatSeconds(UPower.displayDevice.timeToEmpty);
        if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
            return qsTr("Full");
        return formatSeconds(UPower.displayDevice.timeToFull);
    }

    function batteryAccent(): color {
        if (!UPower.displayDevice.isLaptopBattery)
            return Colours.palette.m3primary;
        if (UPower.onBattery && UPower.displayDevice.percentage <= 0.2)
            return Colours.palette.m3error;
        if (UPower.onBattery && UPower.displayDevice.percentage <= 0.4)
            return Colours.palette.m3tertiary;
        return Colours.palette.m3primary;
    }

    function networkTitle(): string {
        if (Network.active)
            return Network.active.ssid;
        if (Network.activeEthernet)
            return Network.activeEthernet.connection || Network.activeEthernet.interface || qsTr("Ethernet");
        return Network.wifiEnabled ? qsTr("Disconnected") : qsTr("Wi-Fi off");
    }

    function networkSubtitle(): string {
        if (Network.active)
            return qsTr("Wi-Fi · %1% signal").arg(Network.active.strength);
        if (Network.activeEthernet)
            return qsTr("Ethernet connected");
        return Network.wifiEnabled ? qsTr("No active network") : qsTr("Wireless disabled");
    }

    function networkIcon(): string {
        if (Network.active)
            return "wifi";
        if (Network.activeEthernet)
            return "settings_ethernet";
        return "wifi_off";
    }

    Component.onCompleted: SystemUsage.refCount++
    Component.onDestruction: SystemUsage.refCount = Math.max(0, SystemUsage.refCount - 1)

    StyledRect {
        anchors.fill: parent
        radius: Tokens.rounding.large
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                MetricCard {
                    Layout.fillWidth: true
                    title: qsTr("CPU")
                    icon: "memory"
                    valueText: root.percent(SystemUsage.cpuPerc)
                    detailText: SystemUsage.cpuName || qsTr("Processor")
                    progress: SystemUsage.cpuPerc
                    accent: root.cpuColour
                    statOneIcon: "speed"
                    statOneLabel: qsTr("Clock")
                    statOneValue: root.frequencyText(SystemUsage.cpuFreqMhz)
                    statTwoIcon: "device_thermostat"
                    statTwoLabel: qsTr("Temp")
                    statTwoValue: root.tempText(SystemUsage.cpuTemp)
                    statTwoAccent: root.thermalAccent(SystemUsage.cpuTemp)
                }

                MetricCard {
                    Layout.fillWidth: true
                    title: qsTr("Memory")
                    icon: "dataset"
                    valueText: root.percent(SystemUsage.memPerc)
                    detailText: `${root.formatKib(SystemUsage.memUsed)} / ${root.formatKib(SystemUsage.memTotal)}`
                    progress: SystemUsage.memPerc
                    accent: root.memoryColour
                    statOneIcon: "memory_alt"
                    statOneLabel: qsTr("Used")
                    statOneValue: root.formatKib(SystemUsage.memUsed)
                    statTwoIcon: "check_circle"
                    statTwoLabel: qsTr("Free")
                    statTwoValue: root.formatKib(Math.max(0, SystemUsage.memTotal - SystemUsage.memUsed))
                    statTwoAccent: Colours.palette.m3tertiary
                }

                MetricCard {
                    Layout.fillWidth: true
                    title: qsTr("Disk")
                    icon: "hard_disk"
                    valueText: root.percent(root.mainDisk?.perc ?? SystemUsage.storagePerc)
                    detailText: root.mainDisk ? `${root.formatKib(root.mainDisk.used)} / ${root.formatKib(root.mainDisk.total)}` : qsTr("Storage")
                    progress: root.mainDisk?.perc ?? SystemUsage.storagePerc
                    accent: root.diskColour
                    statOneIcon: "folder"
                    statOneLabel: qsTr("Free")
                    statOneValue: root.mainDisk ? root.formatKib(root.mainDisk.free) : "--"
                    statTwoIcon: "device_thermostat"
                    statTwoLabel: qsTr("Temp")
                    statTwoValue: root.tempText(SystemUsage.diskTemp)
                    statTwoAccent: root.thermalAccent(SystemUsage.diskTemp)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Tokens.spacing.small

                StatusCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "battery_charging_full"
                    title: qsTr("Battery")
                    valueText: root.batteryText()
                    subtitle: root.batteryStatusText()
                    accent: root.batteryAccent()

                    InfoRow {
                        icon: root.powerProfileIcon()
                        label: qsTr("Profile")
                        value: root.powerProfileText()
                        accent: root.batteryAccent()
                    }

                    InfoRow {
                        icon: UPower.onBattery ? "schedule" : "bolt"
                        label: UPower.onBattery ? qsTr("Remaining") : qsTr("To full")
                        value: root.batteryTimeText()
                        accent: root.batteryAccent()
                    }

                    InfoRow {
                        icon: "device_thermostat"
                        label: qsTr("Thermal")
                        value: root.tempText(SystemUsage.batteryTemp)
                        accent: root.thermalAccent(SystemUsage.batteryTemp)
                        visible: SystemUsage.batteryTemp > 0
                    }
                }

                StatusCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: root.networkIcon()
                    title: qsTr("Network")
                    valueText: root.networkTitle()
                    subtitle: root.networkSubtitle()
                    accent: Network.active || Network.activeEthernet ? Colours.palette.m3tertiary : Colours.palette.m3onSurfaceVariant

                    InfoRow {
                        icon: "south"
                        label: qsTr("Down")
                        value: root.rateText(SystemUsage.netDownRate)
                        accent: Colours.palette.m3tertiary
                    }

                    InfoRow {
                        icon: "north"
                        label: qsTr("Up")
                        value: root.rateText(SystemUsage.netUpRate)
                        accent: Colours.palette.m3primary
                    }

                    InfoRow {
                        icon: "data_usage"
                        label: qsTr("Used")
                        value: `↓ ${root.formatBytes(SystemUsage.netRxBytes)} / ↑ ${root.formatBytes(SystemUsage.netTxBytes)}`
                        accent: Network.active || Network.activeEthernet ? Colours.palette.m3tertiary : Colours.palette.m3onSurfaceVariant
                    }
                }
            }
        }
    }

    component MetricCard: StyledRect {
        id: card

        required property string title
        required property string icon
        required property string valueText
        required property string detailText
        required property real progress
        required property color accent
        required property string statOneIcon
        required property string statOneLabel
        required property string statOneValue
        required property string statTwoIcon
        required property string statTwoLabel
        required property string statTwoValue
        property color statOneAccent: accent
        property color statTwoAccent: accent
        property bool hovered: false

        Layout.preferredHeight: 178
        radius: Tokens.rounding.large
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, hovered ? 2 : 1)
        border.width: 1
        border.color: Qt.alpha(accent, hovered ? 0.32 : 0.14)

        HoverHandler {
            onHoveredChanged: card.hovered = hovered
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.smaller

                        MaterialIcon {
                            text: card.icon
                            color: card.accent
                            fill: 1
                            font.pointSize: Tokens.font.size.large
                        }

                        StyledText {
                            text: card.title
                            color: Colours.palette.m3onSurface
                            font.weight: 650
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: card.detailText
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Tokens.font.size.small
                        elide: Text.ElideRight
                    }
                }

                Item {
                    Layout.preferredWidth: 94
                    Layout.preferredHeight: 94
                    Layout.alignment: Qt.AlignVCenter

                    CircularProgress {
                        anchors.fill: parent
                        value: root.clamp01(card.progress)
                        strokeWidth: 7
                        fgColour: card.accent
                        bgColour: Qt.alpha(card.accent, 0.16)
                        spacing: Tokens.spacing.smaller
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            text: card.icon
                            color: card.accent
                            fill: 1
                            font.pointSize: Tokens.font.size.normal
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: card.valueText
                            color: Colours.palette.m3onSurface
                            font.family: Tokens.font.family.mono
                            font.pointSize: Tokens.font.size.normal
                            font.weight: 700
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StatPill {
                    Layout.fillWidth: true
                    icon: card.statOneIcon
                    label: card.statOneLabel
                    value: card.statOneValue
                    accent: card.statOneAccent
                }

                StatPill {
                    Layout.fillWidth: true
                    icon: card.statTwoIcon
                    label: card.statTwoLabel
                    value: card.statTwoValue
                    accent: card.statTwoAccent
                }
            }
        }

        Behavior on color {
            CAnim {
                duration: 140
            }
        }

        Behavior on border.color {
            CAnim {
                duration: 140
            }
        }
    }

    component StatusCard: StyledRect {
        id: card

        required property string icon
        required property string title
        required property string valueText
        required property string subtitle
        required property color accent
        default property alias content: extraContent.data
        property bool hovered: false

        radius: Tokens.rounding.large
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, hovered ? 2 : 1)
        border.width: 1
        border.color: Qt.alpha(accent, hovered ? 0.30 : 0.12)

        HoverHandler {
            onHoveredChanged: card.hovered = hovered
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            StyledRect {
                implicitWidth: 46
                implicitHeight: 46
                radius: Tokens.rounding.full
                color: Qt.alpha(card.accent, 0.14)

                MaterialIcon {
                    anchors.centerIn: parent
                    text: card.icon
                    color: card.accent
                    fill: 1
                    font.pointSize: Tokens.font.size.extraLarge
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.smaller

                StyledText {
                    Layout.fillWidth: true
                    text: card.title
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: card.valueText
                    color: card.accent
                    font.family: Tokens.font.family.mono
                    font.pointSize: Tokens.font.size.large
                    font.weight: 700
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: card.subtitle
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }

                ColumnLayout {
                    id: extraContent

                    Layout.fillWidth: true
                    spacing: Tokens.spacing.smaller
                }
            }
        }
    }

    component StatPill: StyledRect {
        required property string icon
        required property string label
        required property string value
        required property color accent

        implicitHeight: 44
        radius: Tokens.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)

        RowLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.small
            spacing: Tokens.spacing.smaller

            MaterialIcon {
                text: icon
                color: accent
                fill: 1
                font.pointSize: Tokens.font.size.normal
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: label
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: value
                    color: Colours.palette.m3onSurface
                    font.family: Tokens.font.family.mono
                    font.pointSize: Tokens.font.size.small
                    font.weight: 650
                    elide: Text.ElideRight
                }
            }
        }
    }

    component InfoRow: RowLayout {
        required property string icon
        required property string label
        required property string value
        required property color accent

        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        MaterialIcon {
            text: icon
            color: accent
            fill: 1
            font.pointSize: Tokens.font.size.normal
        }

        StyledText {
            Layout.fillWidth: true
            text: label
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Tokens.font.size.small
            elide: Text.ElideRight
        }

        StyledText {
            text: value
            color: Colours.palette.m3onSurface
            font.family: Tokens.font.family.mono
            font.pointSize: Tokens.font.size.small
            font.weight: 650
        }
    }
}
