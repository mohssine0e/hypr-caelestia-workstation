-- Inactive verification entrypoint through the keybinds migration slice.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

require("modules.input")
require("modules.general")
require("modules.decoration")
require("modules.animations")
require("modules.misc")
require("modules.group")
require("modules.gestures")
require("modules.scrolling")
require("modules.env")
require("modules.execs")
require("modules.rules")
require("modules.keybinds")
