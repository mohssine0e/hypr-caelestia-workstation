import "dash"
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.filedialog
import qs.services

GridLayout {
    id: root

    required property DrawerVisibilities visibilities
    required property DashboardState dashState
    required property FileDialog facePicker

    readonly property bool needsKeyboard: calendar.needsKeyboard

    function focusPrimaryInput(): void {
        calendar.focusPrimaryInput();
    }

    rowSpacing: Tokens.spacing.normal
    columnSpacing: Tokens.spacing.normal

    Rect {
        Layout.row: 0
        Layout.column: 0
        Layout.columnSpan: 2
        Layout.preferredWidth: user.implicitWidth
        Layout.preferredHeight: user.implicitHeight

        radius: Tokens.rounding.large

        User {
            id: user

            visibilities: root.visibilities
            facePicker: root.facePicker
        }
    }

    Rect {
        Layout.row: 0
        Layout.column: 2
        Layout.preferredWidth: dateTime.implicitWidth
        Layout.minimumWidth: dateTime.implicitWidth
        Layout.fillHeight: true

        radius: Tokens.rounding.normal

        DateTime {
            id: dateTime
        }
    }

    Rect {
        Layout.row: 1
        Layout.column: 0
        Layout.columnSpan: 3
        Layout.fillWidth: true
        Layout.preferredHeight: calendar.implicitHeight

        radius: Tokens.rounding.large

        Calendar {
            id: calendar

            dashState: root.dashState
        }
    }

    Rect {
        Layout.row: 0
        Layout.column: 3
        Layout.rowSpan: 2
        Layout.preferredWidth: media.implicitWidth
        Layout.fillHeight: true

        radius: Tokens.rounding.large * 2

        Media {
            id: media
        }
    }

    component Rect: StyledRect {
        color: Colours.tPalette.m3surfaceContainer
    }
}
