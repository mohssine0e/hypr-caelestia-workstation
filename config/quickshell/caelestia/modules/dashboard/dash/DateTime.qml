pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    anchors.fill: parent
    implicitWidth: Math.round(Tokens.sizes.dashboard.dateTimeWidth * 1.65)

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - Tokens.padding.large * 2
        spacing: Tokens.spacing.small

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Tokens.spacing.smaller

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Time.format("HH")
                color: Colours.palette.m3secondary
                font.pointSize: Tokens.font.size.extraLarge * 1.35
                font.family: Tokens.font.family.clock
                font.weight: 700
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: ":"
                color: Colours.palette.m3primary
                font.pointSize: Tokens.font.size.extraLarge * 1.2
                font.family: Tokens.font.family.clock
                font.weight: 700
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Time.format("mm")
                color: Colours.palette.m3secondary
                font.pointSize: Tokens.font.size.extraLarge * 1.35
                font.family: Tokens.font.family.clock
                font.weight: 700
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            text: Time.format("ddd, d MMM")
            color: Colours.palette.m3onSurfaceVariant
            font.family: Tokens.font.family.mono
            font.pointSize: Tokens.font.size.small
            font.weight: 700
            elide: Text.ElideRight
        }
    }
}
