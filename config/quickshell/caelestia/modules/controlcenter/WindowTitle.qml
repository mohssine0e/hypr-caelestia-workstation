import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    required property ShellScreen screen
    required property Session session

    implicitHeight: text.implicitHeight + Tokens.padding.normal
    color: Colours.tPalette.m3surfaceContainer

    StyledText {
        id: text

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        text: qsTr("Caelestia Settings - %1").arg(root.session.active)
        font.capitalization: Font.Capitalize
        font.pointSize: Tokens.font.size.larger
        font.weight: 500
    }

}
