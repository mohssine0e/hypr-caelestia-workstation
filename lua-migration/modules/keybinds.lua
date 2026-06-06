local values = require("modules.values")

-- Equivalent of config/hypr/hyprland/keybinds.conf.

local wsaction = "~/.config/hypr/scripts/wsaction.fish"

local kb = {
    session = "CTRL + ALT + Delete",
    showBar = "SUPER + A",
    showDashboard = "SUPER + D",
    showSidebar = "SUPER + N",
    clearNotifs = "CTRL + ALT + C",
    showPanels = "SUPER + K",
    lock = "SUPER + L",
    restoreLock = "SUPER + ALT + L",

    goToWs = "SUPER",
    goToWsGroup = "CTRL + SUPER",
    prevWs = "CTRL + SUPER + left",
    nextWs = "CTRL + SUPER + right",
    toggleSpecialWs = "SUPER + S",
    moveWinToWs = "SUPER + ALT",
    moveWinToWsGroup = "CTRL + SUPER + ALT",

    windowGroupCycleNext = "ALT + Tab",
    windowGroupCyclePrev = "SHIFT + ALT + Tab",
    ungroup = "SUPER + U",
    toggleGroup = "SUPER + Comma",

    moveWindow = "SUPER + Z",
    resizeWindow = "SUPER + X",
    windowPip = "SUPER + ALT + Backslash",
    pinWindow = "SUPER + P",
    windowFullscreen = "SUPER + F",
    windowBorderedFullscreen = "SUPER + ALT + F",
    toggleWindowFloating = "SUPER + ALT + Space",
    closeWindow = "SUPER + Q",

    systemMonitor = "CTRL + SHIFT + Escape",
    music = "SUPER + M",
    communication = "SUPER + ALT + D",
    todo = "SUPER + R",

    terminal = "SUPER + T",
    browser = "SUPER + B",
    editor = "SUPER + C",
    fileExplorer = "SUPER + E",
}

local locked = { locked = true }
local repeating = { repeating = true }
local locked_repeating = { locked = true, repeating = true }
local release = { release = true }
local mouse = { mouse = true }
local ignore_mods = { ignore_mods = true }
local ignore_mods_non_consuming = { ignore_mods = true, non_consuming = true }

local function bind(key, dispatcher, opts)
    hl.bind(key, dispatcher, opts)
end

local function exec(key, command, opts)
    bind(key, hl.dsp.exec_cmd(command), opts)
end

local function global(key, name, opts)
    bind(key, hl.dsp.global(name), opts)
end

local function raw(key, dispatcher, arg, opts)
    if arg == nil then
        bind(key, hl.dsp.exec_raw(dispatcher), opts)
    else
        bind(key, hl.dsp.exec_raw(dispatcher, arg), opts)
    end
end

local function mod_key(mods, key)
    if mods == "" then
        return key
    end
    return mods .. " + " .. key
end

hl.on("hyprland.start", function()
    hl.dispatch(hl.dsp.submap("global"))
end)

hl.define_submap("global", function()
    -- Shell keybinds: launcher
    global("SUPER + Super_L", "caelestia:launcher", ignore_mods)
    -- TODO: Hyprland Lua 0.55.2 does not parse modifier-scoped catchall
    -- key strings such as "SUPER + catchall". Keep this omitted instead of
    -- replacing it with a broad unmodified catchall.
    for _, key in ipairs({ "mouse:272", "mouse:273", "mouse:274", "mouse:275", "mouse:276", "mouse:277", "mouse_up", "mouse_down" }) do
        global("SUPER + " .. key, "caelestia:launcherInterrupt", ignore_mods_non_consuming)
    end

    -- Misc
    global(kb.session, "caelestia:session")
    global(kb.showBar, "caelestia:bar")
    global(kb.showDashboard, "caelestia:dashboard")
    global(kb.showSidebar, "caelestia:sidebar")
    global(kb.clearNotifs, "caelestia:clearNotifs", locked)
    global(kb.showPanels, "caelestia:showall")
    global(kb.lock, "caelestia:lock")

    -- Restore lock
    exec(kb.restoreLock, "caelestia shell -d", locked)
    global(kb.restoreLock, "caelestia:lock", locked)

    -- Brightness
    global("XF86MonBrightnessUp", "caelestia:brightnessUp", locked)
    global("XF86MonBrightnessDown", "caelestia:brightnessDown", locked)

    -- Media
    global("SUPER + End", "caelestia:mediaToggle", locked)
    global("CTRL + SUPER + Space", "caelestia:mediaToggle", locked)
    global("XF86AudioPlay", "caelestia:mediaToggle", locked)
    global("XF86AudioPause", "caelestia:mediaToggle", locked)
    global("CTRL + SUPER + Equal", "caelestia:mediaNext", locked)
    global("XF86AudioNext", "caelestia:mediaNext", locked)
    global("CTRL + SUPER + Minus", "caelestia:mediaPrev", locked)
    global("XF86AudioPrev", "caelestia:mediaPrev", locked)
    global("XF86AudioStop", "caelestia:mediaStop", locked)

    -- Kill/restart
    exec("CTRL + SUPER + SHIFT + R", "qs -c caelestia kill", release)
    exec("CTRL + SUPER + ALT + R", "qs -c caelestia kill; sleep .1; caelestia shell -d", release)

    -- Go to workspace #
    for i = 1, 10 do
        local key = tostring(i % 10)
        exec(mod_key(kb.goToWs, key), ("%s workspace %s"):format(wsaction, i))
        exec(mod_key(kb.goToWsGroup, key), ("%s -g workspace %s"):format(wsaction, i))
    end

    -- Go to workspace -1/+1
    raw("SUPER + mouse_down", "workspace", "-1")
    raw("SUPER + mouse_up", "workspace", "+1")
    raw(kb.prevWs, "workspace", "-1", repeating)
    raw(kb.nextWs, "workspace", "+1", repeating)
    raw("SUPER + Page_Up", "workspace", "-1", repeating)
    raw("SUPER + Page_Down", "workspace", "+1", repeating)

    -- Go to workspace group -1/+1
    raw("CTRL + SUPER + mouse_down", "workspace", "-10")
    raw("CTRL + SUPER + mouse_up", "workspace", "+10")

    -- Toggle special workspace
    exec(kb.toggleSpecialWs, "caelestia toggle specialws")

    -- Move window to workspace #
    for i = 1, 10 do
        local key = tostring(i % 10)
        exec(mod_key(kb.moveWinToWs, key), ("%s movetoworkspace %s"):format(wsaction, i))
        exec(mod_key(kb.moveWinToWsGroup, key), ("%s -g movetoworkspace %s"):format(wsaction, i))
    end

    -- Move window to workspace -1/+1
    raw("SUPER + ALT + Page_Up", "movetoworkspace", "-1", repeating)
    raw("SUPER + ALT + Page_Down", "movetoworkspace", "+1", repeating)
    raw("SUPER + ALT + mouse_down", "movetoworkspace", "-1")
    raw("SUPER + ALT + mouse_up", "movetoworkspace", "+1")
    raw("CTRL + SUPER + SHIFT + right", "movetoworkspace", "+1", repeating)
    raw("CTRL + SUPER + SHIFT + left", "movetoworkspace", "-1", repeating)

    -- Move window to/from special workspace
    raw("CTRL + SUPER + SHIFT + up", "movetoworkspace", "special:special")
    raw("CTRL + SUPER + SHIFT + down", "movetoworkspace", "e+0")
    raw("SUPER + ALT + S", "movetoworkspace", "special:special")

    -- Window groups
    raw(kb.windowGroupCycleNext, "cyclenext", nil, repeating)
    raw(kb.windowGroupCyclePrev, "cyclenext", "prev", repeating)
    raw("CTRL + ALT + Tab", "changegroupactive", "f", repeating)
    raw("CTRL + SHIFT + ALT + Tab", "changegroupactive", "b", repeating)
    raw(kb.toggleGroup, "togglegroup")
    raw(kb.ungroup, "moveoutofgroup")
    raw("SUPER + SHIFT + Comma", "lockactivegroup", "toggle")

    -- Window actions
    raw("SUPER + left", "movefocus", "l")
    raw("SUPER + right", "movefocus", "r")
    raw("SUPER + up", "movefocus", "u")
    raw("SUPER + down", "movefocus", "d")
    raw("SUPER + SHIFT + left", "movewindow", "l")
    raw("SUPER + SHIFT + right", "movewindow", "r")
    raw("SUPER + SHIFT + up", "movewindow", "u")
    raw("SUPER + SHIFT + down", "movewindow", "d")
    raw("SUPER + Minus", "resizeactive", "-10% 0", repeating)
    raw("SUPER + Equal", "resizeactive", "10% 0", repeating)
    raw("SUPER + SHIFT + Minus", "resizeactive", "0 -10%", repeating)
    raw("SUPER + SHIFT + Equal", "resizeactive", "0 10%", repeating)
    raw("SUPER + ALT + left", "resizeactive", "-10% 0", repeating)
    raw("SUPER + ALT + right", "resizeactive", "10% 0", repeating)
    raw("SUPER + ALT + up", "resizeactive", "0 -10%", repeating)
    raw("SUPER + ALT + down", "resizeactive", "0 10%", repeating)
    raw("SUPER + mouse:272", "movewindow", nil, mouse)
    raw(kb.moveWindow, "movewindow", nil, mouse)
    raw("SUPER + mouse:273", "resizewindow", nil, mouse)
    raw(kb.resizeWindow, "resizewindow", nil, mouse)
    raw("CTRL + SUPER + Backslash", "centerwindow", "1")
    raw("CTRL + SUPER + ALT + Backslash", "resizeactive", "exact 55% 70%")
    raw("CTRL + SUPER + ALT + Backslash", "centerwindow", "1")
    exec(kb.windowPip, "caelestia resizer pip")
    raw(kb.pinWindow, "pin")
    raw(kb.windowFullscreen, "fullscreen", "0")
    raw(kb.windowBorderedFullscreen, "fullscreen", "1")
    raw(kb.toggleWindowFloating, "togglefloating")
    raw(kb.closeWindow, "killactive")

    -- Special workspace toggles
    exec(kb.systemMonitor, "caelestia toggle sysmon")
    exec(kb.music, "caelestia toggle music")
    exec(kb.communication, "caelestia toggle communication")
    exec(kb.todo, "caelestia toggle todo")

    -- Apps
    exec(kb.terminal, "app2unit -- " .. values.terminal)
    exec(kb.browser, "app2unit -- " .. values.browser)
    exec(kb.editor, "app2unit -- " .. values.editor)
    exec("SUPER + G", "app2unit -- github-desktop")
    exec(kb.fileExplorer, "app2unit -- " .. values.fileExplorer)
    exec("SUPER + ALT + E", "app2unit -- nemo")
    exec("CTRL + ALT + Escape", "app2unit -- qps")
    exec("CTRL + ALT + V", "app2unit -- pavucontrol")

    -- Utilities
    exec("Print", "caelestia screenshot", locked)
    exec("SUPER + SHIFT + S", "hyprshot -m region --clipboard-only -z -s")
    global("SUPER + SHIFT + ALT + S", "caelestia:screenshot")
    exec("SUPER + ALT + R", "caelestia record -s")
    exec("CTRL + ALT + R", "caelestia record")
    exec("SUPER + SHIFT + ALT + R", "caelestia record -r")
    exec("SUPER + SHIFT + C", "hyprpicker -a")

    -- Volume
    exec("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", locked)
    exec("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", locked)
    exec("SUPER + SHIFT + M", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", locked)
    exec("XF86AudioRaiseVolume", ("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ %s%%+"):format(values.volumeStep), locked_repeating)
    exec("XF86AudioLowerVolume", ("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ %s%%-"):format(values.volumeStep), locked_repeating)

    -- Sleep
    exec("SUPER + SHIFT + L", "systemctl suspend-then-hibernate", locked)

    -- Clipboard and emoji picker
    exec("SUPER + V", "pkill fuzzel || caelestia clipboard")
    exec("SUPER + SHIFT + V", "pkill fuzzel || caelestia clipboard -d")
    exec("SUPER + Period", "pkill fuzzel || caelestia emoji -p")
    exec("CTRL + SHIFT + ALT + V", [[sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"]], locked)

    -- Testing
    exec("SUPER + ALT + F12", [[notify-send -u low -i dialog-information-symbolic 'Test notification' "Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!" -a 'Shell' -A "Test1=I got it!" -A "Test2=Another action"]], locked)
end)
