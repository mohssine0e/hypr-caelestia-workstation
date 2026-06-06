-- Inactive verification entrypoint through the decoration migration slice.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

require("modules.input")
require("modules.general")
require("modules.decoration")
