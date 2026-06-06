import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.misc
import qs.services

Item {
    id: root

    // Change this number to tune the lock-screen performance circle size.
    property int targetCircleSize: 210
    readonly property int circleSize: Math.round(Math.max(136, Math.min(targetCircleSize, (width - Tokens.spacing.small * 3 - Tokens.padding.normal * 2) / 4)))

    implicitWidth: metricRow.implicitWidth + Tokens.padding.normal * 2
    implicitHeight: layout.implicitHeight + Tokens.padding.normal * 2

    Ref {
        service: SystemUsage
    }

    ColumnLayout {
        id: layout

        anchors.centerIn: parent
        width: parent.width - Tokens.padding.normal * 2
        spacing: Tokens.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            visible: batteryPill.visible

            Item {
                Layout.fillWidth: true
            }

            BatteryPill {
                id: batteryPill
            }
        }

        RowLayout {
            id: metricRow

            Layout.alignment: Qt.AlignHCenter
            spacing: Tokens.spacing.small

            MetricCircle {
                label: qsTr("CPU")
                icon: "memory"
                value: SystemUsage.cpuPerc
                valueText: `${Math.round(SystemUsage.cpuPerc * 100)}%`
                colour: Colours.palette.m3primary
            }

            MetricCircle {
                label: qsTr("TEMP")
                icon: "thermostat"
                value: Math.min(1, SystemUsage.cpuTemp / 90)
                valueText: `${Math.round(Math.min(1, SystemUsage.cpuTemp / 90) * 100)}%`
                colour: Colours.palette.m3secondary
            }

            MetricCircle {
                label: qsTr("RAM")
                icon: "memory_alt"
                value: SystemUsage.memPerc
                valueText: `${Math.round(SystemUsage.memPerc * 100)}%`
                colour: Colours.palette.m3secondary
            }

            MetricCircle {
                label: qsTr("DISK")
                icon: "hard_disk"
                value: SystemUsage.storagePerc
                valueText: `${Math.round(SystemUsage.storagePerc * 100)}%`
                colour: Colours.palette.m3tertiary
            }
        }
    }

    component BatteryPill: StyledRect {
        id: pill

        readonly property real percentage: UPower.displayDevice.percentage
        readonly property bool charging: [UPowerDeviceState.Charging, UPowerDeviceState.PendingCharge].includes(UPower.displayDevice.state)

        visible: UPower.displayDevice.isLaptopBattery
        implicitWidth: pillContent.implicitWidth + Tokens.padding.normal * 2
        implicitHeight: pillContent.implicitHeight + Tokens.padding.small * 2
        radius: Tokens.rounding.full
        color: Qt.rgba(0, 0, 0, 0.34)

        RowLayout {
            id: pillContent

            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: pill.charging ? "battery_charging_full" : "battery_full"
                color: pill.charging ? Colours.palette.m3primary : Colours.palette.m3tertiary
                font.pointSize: Tokens.font.size.normal
                fill: 1
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: `${Math.round(pill.percentage * 100)}%`
                color: Colours.palette.m3onSurface
                font.family: Tokens.font.family.mono
                font.pointSize: Tokens.font.size.small
                font.weight: 800
            }
        }
    }

    component MetricCircle: StyledRect {
        id: metric

        required property string label
        required property string icon
        required property real value
        required property string valueText
        required property color colour

        Layout.preferredWidth: root.circleSize
        Layout.preferredHeight: root.circleSize
        implicitWidth: root.circleSize
        implicitHeight: root.circleSize
        radius: Tokens.rounding.full
        color: Qt.rgba(0, 0, 0, 0.28)

        CircularProgress {
            id: progress

            anchors.fill: parent
            padding: Tokens.padding.normal
            value: metric.value
            fgColour: metric.colour
            bgColour: Qt.rgba(1, 1, 1, 0.08)
            strokeWidth: Math.max(5, width * 0.055)
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: metric.icon
                color: metric.colour
                fill: 1
                font.pointSize: Math.max(Tokens.font.size.normal, progress.arcRadius * 0.34)
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: metric.valueText
                color: metric.colour
                font.family: Tokens.font.family.mono
                font.pointSize: Math.max(Tokens.font.size.small, progress.arcRadius * 0.22)
                font.weight: 800
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: metric.label
                color: Colours.palette.m3onSurfaceVariant
                font.family: Tokens.font.family.mono
                font.pointSize: Tokens.font.size.smaller
                font.weight: 700
            }
        }

        Behavior on value {
            Anim {
                type: Anim.StandardLarge
            }
        }
    }
}
