local values = require("modules.values")

-- Equivalent of config/hypr/hyprland/group.conf.
hl.config({
    group = {
        col = {
            border_active = values.activeWindowBorderColour,
            border_inactive = values.inactiveWindowBorderColour,
            border_locked_active = values.activeWindowBorderColour,
            border_locked_inactive = values.inactiveWindowBorderColour,
        },

        groupbar = {
            font_family = "JetBrains Mono NF",
            font_size = 15,
            gradients = true,
            gradient_round_only_edges = false,
            gradient_rounding = 5,
            height = 25,
            indicator_height = 0,
            gaps_in = 3,
            gaps_out = 3,

            text_color = values.onPrimaryColour,
            col = {
                active = values.primaryD4Colour,
                inactive = values.outlineD4Colour,
                locked_active = values.primaryD4Colour,
                locked_inactive = values.secondaryD4Colour,
            },
        },
    },
})
