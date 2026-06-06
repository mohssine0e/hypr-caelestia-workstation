local values = require("modules.values")

-- Equivalent of config/hypr/hyprland/decoration.conf.
hl.config({
    decoration = {
        rounding = values.windowRounding,

        blur = {
            enabled = values.blurEnabled,
            xray = values.blurXray,
            special = values.blurSpecialWs,
            ignore_opacity = true,
            new_optimizations = true,
            popups = values.blurPopups,
            input_methods = values.blurInputMethods,
            size = values.blurSize,
            passes = values.blurPasses,
        },

        shadow = {
            enabled = values.shadowEnabled,
            range = values.shadowRange,
            render_power = values.shadowRenderPower,
            color = values.shadowColour,
        },
    },
})
