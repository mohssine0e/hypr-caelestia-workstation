pragma ComponentBehavior: Bound

import ".."
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services

CollapsibleSection {
    title: qsTr("Theme mode")
    description: qsTr("Light or dark theme")
    showBackground: true

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        TextButton {
            Layout.fillWidth: true
            text: qsTr("Light")
            type: Colours.currentLight ? TextButton.Filled : TextButton.Tonal
            onClicked: Colours.setMode("light")
        }

        TextButton {
            Layout.fillWidth: true
            text: qsTr("Dark")
            type: !Colours.currentLight ? TextButton.Filled : TextButton.Tonal
            onClicked: Colours.setMode("dark")
        }
    }

    StyledText {
        Layout.fillWidth: true
        text: Colours.currentLight ? qsTr("Light mode active") : qsTr("Dark mode active")
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Tokens.font.size.small
    }
}
