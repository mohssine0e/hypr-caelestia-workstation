-- Inactive verification entrypoint through the group migration slice.
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
