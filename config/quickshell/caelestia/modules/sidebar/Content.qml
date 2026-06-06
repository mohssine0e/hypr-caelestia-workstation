import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.modules.bar.popouts as BarPopouts
import qs.modules.utilities.cards as UtilityCards
import qs.services

Item {
    id: root

    required property Props props
    required property var utilityProps
    required property DrawerVisibilities visibilities
    required property BarPopouts.Wrapper popouts

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: Tokens.spacing.normal

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Tokens.rounding.normal
            color: Colours.tPalette.m3surfaceContainerLow

            NotifDock {
                props: root.props
                visibilities: root.visibilities
            }
        }

        StyledRect {
            id: utilitiesCard

            Layout.fillWidth: true
            implicitHeight: Math.min(layout.height * 0.45, utilitiesColumn.implicitHeight + Tokens.padding.normal * 2)

            radius: Tokens.rounding.normal
            color: Colours.tPalette.m3surfaceContainerLow
            clip: true

            StyledFlickable {
                id: utilitiesView

                anchors.fill: parent
                anchors.margins: Tokens.padding.normal
                contentWidth: width
                contentHeight: Math.max(height, utilitiesColumn.implicitHeight)
                flickableDirection: Flickable.VerticalFlick

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: utilitiesView
                }

                ColumnLayout {
                    id: utilitiesColumn

                    y: Math.max(0, utilitiesView.height - implicitHeight)
                    width: utilitiesView.width
                    spacing: Tokens.spacing.small

                    UtilityCards.IdleInhibit {}

                    UtilityCards.Record {
                        props: root.utilityProps
                        visibilities: root.visibilities
                    }

                    UtilityCards.Toggles {
                        visibilities: root.visibilities
                        popouts: root.popouts
                    }
                }
            }
        }
    }
}
