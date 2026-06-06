-- Equivalent of config/caelestia/hypr-user.conf.

local function dispatch(dispatcher, arg)
    return function()
        hl.dispatch(hl.dsp.exec_raw(dispatcher, arg))
    end
end

-- Custom touchpad gestures: move the active tiled window with a 3-finger swipe.
for direction, arg in pairs({
    left = "l",
    right = "r",
    up = "u",
    down = "d",
}) do
    hl.gesture({
        fingers = 3,
        direction = direction,
        action = dispatch("movewindow", arg),
    })
end

hl.config({
    -- Let window borders be grabbed with the mouse for resizing.
    general = {
        resize_on_border = true,
    },

    -- Privacy: keep session lock surfaces isolated from the unlocked session.
    misc = {
        session_lock_xray = false,
    },
})

-- Display switcher, GNOME-style. The default SUPER+P pin shortcut is moved
-- to SUPER+ALT+P so SUPER+P can control laptop/external display modes.
hl.unbind("SUPER + P")
hl.bind("SUPER + P", hl.dsp.exec_cmd("~/.config/caelestia/scripts/display-menu.sh"))
hl.bind("SUPER + ALT + P", hl.dsp.exec_raw("pin"))

-- Full settings fallback. Caelestia covers daily shell controls; GNOME Settings
-- covers the deeper system panels like users, printers, privacy and details.
hl.bind("SUPER + I", hl.dsp.exec_cmd("app2unit -- ~/.config/caelestia/scripts/gnome-settings.sh"))
hl.bind("SUPER + SHIFT + I", hl.dsp.global("caelestia:systemControl"))

-- Keep only GNOME Files/Nautilus in the daily workflow.
hl.unbind("SUPER + ALT + E")
