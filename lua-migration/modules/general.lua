local values = require("modules.values")

-- Equivalent of config/hypr/hyprland/general.conf.
hl.config({
    general = {
        layout = "dwindle",
        allow_tearing = false,

        gaps_workspaces = values.workspaceGaps,
        gaps_in = values.windowGapsIn,
        gaps_out = values.windowGapsOut,
        border_size = values.windowBorderSize,

        col = {
            active_border = values.activeWindowBorderColour,
            inactive_border = values.inactiveWindowBorderColour,
        },
    },

    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    },
})
