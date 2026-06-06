-- Inactive full Hyprland Lua migration entrypoint.
-- Do not place this at ~/.config/hypr/hyprland.lua until it is manually approved.

-- Equivalent of the default monitor line in config/hypr/hyprland.conf.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

-- Keep the original source order from config/hypr/hyprland.conf.
require("modules.env")
require("modules.general")
require("modules.input")
require("modules.misc")
require("modules.animations")
require("modules.decoration")
require("modules.group")
require("modules.execs")
require("modules.rules")
require("modules.gestures")
require("modules.keybinds")
require("modules.scrolling")

-- User configs load last in the current graph.
require("modules.user-overrides")
