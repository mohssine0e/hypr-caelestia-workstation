local values = require("modules.values")

-- Equivalent of config/hypr/hyprland/gestures.conf.
hl.config({
    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.15,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true,
    },
})

hl.gesture({
    fingers = values.workspaceSwipeFingers,
    direction = "horizontal",
    action = "workspace",
})
