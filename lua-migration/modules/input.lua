local values = require("modules.values")

-- Equivalent of config/hypr/hyprland/input.conf.
hl.config({
    input = {
        kb_layout = "us,fr,ara",
        kb_options = "grp:win_space_toggle",
        numlock_by_default = false,
        repeat_delay = 250,
        repeat_rate = 35,
        sensitivity = 0.3,
        focus_on_close = 1,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = values.touchpadDisableTyping,
            scroll_factor = values.touchpadScrollFactor,
        },
    },

    binds = {
        scroll_event_delay = 0,
    },

    cursor = {
        hotspot_padding = 1,
    },
})
