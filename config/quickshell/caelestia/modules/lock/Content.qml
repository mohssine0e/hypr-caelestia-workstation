import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

RowLayout {
    id: root

    required property var lock
    readonly property bool hasMedia: Players.active !== null
    readonly property int sidePanelMaxWidth: 900

    spacing: Tokens.spacing.large

    Item {
        Layout.fillWidth: true
    }

    Center {
        id: center

        lock: root.lock
    }

    ColumnLayout {
        Layout.preferredWidth: Math.max(700, Math.min(root.sidePanelMaxWidth, root.width - center.centerWidth - root.spacing))
        Layout.fillWidth: false
        Layout.fillHeight: false
        Layout.alignment: Qt.AlignVCenter
        spacing: Tokens.spacing.normal

        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: resources.implicitHeight
            clip: true

            topRightRadius: Tokens.rounding.large
            bottomRightRadius: mediaCard.visible ? Tokens.rounding.small : Tokens.rounding.large
            radius: Tokens.rounding.small
            color: "transparent"

            Resources {
                id: resources

                anchors.fill: parent
                anchors.margins: Tokens.padding.normal
            }
        }

        StyledClippingRect {
            id: mediaCard

            Layout.fillWidth: true
            Layout.preferredHeight: root.hasMedia ? media.implicitHeight + Tokens.padding.normal : 0
            Layout.maximumHeight: root.hasMedia ? media.implicitHeight + Tokens.padding.normal : 0
            visible: root.hasMedia

            bottomRightRadius: Tokens.rounding.large
            radius: Tokens.rounding.small
            color: "transparent"

            Media {
                id: media

                anchors.verticalCenter: parent.verticalCenter
                lock: root.lock
            }
        }
    }

    Item {
        Layout.fillWidth: true
    }
}
