pragma ComponentBehavior: Bound

import ".."
import "../../components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.filedialog
import qs.services
import qs.utils

CollapsibleSection {
    id: root

    required property var rootPane

    title: qsTr("Wallpaper & desktop")
    description: qsTr("Background, wallpaper, and desktop clock")
    showBackground: true

    FileDialog {
        id: wallpaperPicker

        title: qsTr("Select a wallpaper")
        filterLabel: qsTr("Image files")
        filters: Images.validImageExtensions
        onAccepted: path => Wallpapers.importWallpaper(path)
    }

    SwitchRow {
        label: qsTr("Background enabled")
        checked: rootPane.backgroundEnabled
        onToggled: checked => {
            rootPane.backgroundEnabled = checked;
            rootPane.saveConfig();
        }
    }

    SwitchRow {
        label: qsTr("Wallpaper enabled")
        checked: rootPane.wallpaperEnabled
        onToggled: checked => {
            rootPane.wallpaperEnabled = checked;
            rootPane.saveConfig();
        }
    }

    SectionContainer {
        Layout.fillWidth: true
        contentSpacing: Tokens.spacing.small

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: "wallpaper"
                color: Colours.palette.m3primary
                font.pointSize: Tokens.font.size.larger
                fill: 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Wallpaper folder")
                    color: Colours.palette.m3onSurface
                    font.weight: 600
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Paths.shortenHome(Paths.wallsdir)
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    wrapMode: Text.WrapAnywhere
                }
            }

            TextButton {
                text: qsTr("Choose")
                type: TextButton.Tonal
                onClicked: wallpaperPicker.open()
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Choose any image from disk, or add images to this folder so they appear in the grid on the right.")
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Tokens.font.size.small
            wrapMode: Text.Wrap
        }

        StyledText {
            Layout.fillWidth: true
            visible: !!Wallpapers.actualCurrent
            text: qsTr("Current: %1").arg(Paths.shortenHome(Wallpapers.actualCurrent))
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Tokens.font.size.small
            elide: Text.ElideMiddle
        }
    }

    SwitchRow {
        label: qsTr("Desktop clock")
        checked: rootPane.desktopClockEnabled
        onToggled: checked => {
            rootPane.desktopClockEnabled = checked;
            rootPane.saveConfig();
        }
    }

    SectionContainer {
        id: posContainer

        readonly property var pos: (rootPane.desktopClockPosition || "bottom-right").split("-")
        readonly property string currentV: pos[0] ?? "bottom"
        readonly property string currentH: pos[1] ?? "right"

        function updateClockPos(v: string, h: string): void {
            rootPane.desktopClockPosition = `${v}-${h}`;
            rootPane.saveConfig();
        }

        Layout.fillWidth: true
        visible: rootPane.desktopClockEnabled
        contentSpacing: Tokens.spacing.small
        z: 1

        SplitButtonRow {
            label: qsTr("Vertical")

            menuItems: [
                MenuItem {
                    property string val: "top"

                    text: qsTr("Top")
                    icon: "vertical_align_top"
                },
                MenuItem {
                    property string val: "middle"

                    text: qsTr("Middle")
                    icon: "vertical_align_center"
                },
                MenuItem {
                    property string val: "bottom"

                    text: qsTr("Bottom")
                    icon: "vertical_align_bottom"
                }
            ]

            Component.onCompleted: {
                for (let i = 0; i < menuItems.length; i++) {
                    if (menuItems[i].val === posContainer.currentV)
                        active = menuItems[i];
                }
            }

            onSelected: item => posContainer.updateClockPos(item.val, posContainer.currentH)
        }

        SplitButtonRow {
            label: qsTr("Horizontal")
            expandedZ: 99

            menuItems: [
                MenuItem {
                    property string val: "left"

                    text: qsTr("Left")
                    icon: "align_horizontal_left"
                },
                MenuItem {
                    property string val: "center"

                    text: qsTr("Center")
                    icon: "align_horizontal_center"
                },
                MenuItem {
                    property string val: "right"

                    text: qsTr("Right")
                    icon: "align_horizontal_right"
                }
            ]

            Component.onCompleted: {
                for (let i = 0; i < menuItems.length; i++) {
                    if (menuItems[i].val === posContainer.currentH)
                        active = menuItems[i];
                }
            }

            onSelected: item => posContainer.updateClockPos(posContainer.currentV, item.val)
        }

        SwitchRow {
            label: qsTr("Invert clock colours")
            checked: rootPane.desktopClockInvertColors
            onToggled: checked => {
                rootPane.desktopClockInvertColors = checked;
                rootPane.saveConfig();
            }
        }
    }
}
