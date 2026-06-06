
pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils

Item {
    id: root

    required property Session session

    // General Settings
    property bool enabled: Config.dashboard.enabled ?? true
    property bool showOnHover: Config.dashboard.showOnHover ?? true
    property int mediaUpdateInterval: GlobalConfig.dashboard.mediaUpdateInterval ?? 1000
    property int resourceUpdateInterval: GlobalConfig.dashboard.resourceUpdateInterval ?? 1000
    property int dragThreshold: Config.dashboard.dragThreshold ?? 50

    // Dashboard tabs currently exposed by the lightweight setup.
    property bool showDashboard: Config.dashboard.showDashboard ?? true
    property bool showMedia: Config.dashboard.showMedia ?? true

    function saveConfig() {
        GlobalConfig.dashboard.enabled = root.nabled;
        GlobalConfig.dashboard.showOnHover = root.showOnHover;
        GlobalConfig.dashboard.mediaUpdateInterval = root.mediaUpdateInterval;
        GlobalConfig.dashboard.resourceUpdateInterval = root.resourceUpdateInterval;
        GlobalConfig.dashboard.dragThreshold = root.dragThreshold;
        GlobalConfig.dashboard.showDashboard = root.showDashboard;
        GlobalConfig.dashboard.showMedia = root.showMedia;
    }

    anchors.fill: parent

    ClippingRectangle {
        id: dashboardClippingRect

        anchors.fill: parent
        anchors.margins: Tokens.padding.normal
        anchors.leftMargin: 0
        anchors.rightMargin: Tokens.padding.normal

        radius: dashboardBorder.innerRadius
        color: "transparent"

        Loader {
            id: dashboardLoader

            anchors.fill: parent
            anchors.margins: Tokens.padding.large + Tokens.padding.normal
            anchors.leftMargin: Tokens.padding.large
            anchors.rightMargin: Tokens.padding.large

            asynchronous: true
            sourceComponent: dashboardContentComponent
        }
    }

    InnerBorder {
        id: dashboardBorder

        leftThickness: 0
        rightThickness: Tokens.padding.normal
    }

    Component {
        id: dashboardContentComponent

        StyledFlickable {
            id: dashboardFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: dashboardLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: dashboardFlickable
            }

            ColumnLayout {
                id: dashboardLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                spacing: Tokens.spacing.normal

                RowLayout {
                    spacing: Tokens.spacing.smaller

                    StyledText {
                        text: qsTr("Dashboard")
                        font.pointSize: Tokens.font.size.large
                        font.weight: 500
                    }
                }

                // General Settings Section
                GeneralSection {
                    rootItem: root
                }

            }
        }
    }
}
