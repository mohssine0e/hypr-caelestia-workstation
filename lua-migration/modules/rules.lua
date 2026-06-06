local values = require("modules.values")

-- Equivalent of config/hypr/hyprland/rules.conf.

local function window_rule(name, spec)
    spec.name = name
    hl.window_rule(spec)
end

local function layer_rule(name, spec)
    spec.name = name
    hl.layer_rule(spec)
end

-- Window rules
window_rule("opacity-non-fullscreen", {
    match = { fullscreen = false },
    opacity = ("%s override"):format(values.windowOpacity),
})

window_rule("opaque-native-transparent-apps", {
    match = { class = "foot|equibop|org\\.quickshell|imv|swappy" },
    opaque = true,
})

window_rule("center-floating-wayland", {
    match = { float = true, xwayland = false },
    center = true,
})

-- Float
for _, class in ipairs({
    "guifetch",
    "yad",
    "zenity",
    "wev",
    "org\\.gnome\\.FileRoller",
    "file-roller",
    "blueman-manager",
    "com\\.github\\.GradienceTeam\\.Gradience",
    "feh",
    "imv",
    "system-config-printer",
    "org\\.quickshell",
}) do
    window_rule(("float-class-%s"):format(class:gsub("[^%w]+", "-")), {
        match = { class = class },
        float = true,
    })
end

-- Float, resize and center
window_rule("nmtui-float", { match = { class = "foot", title = "nmtui" }, float = true })
window_rule("nmtui-size", { match = { class = "foot", title = "nmtui" }, size = "60% 70%" })
window_rule("nmtui-center", { match = { class = "foot", title = "nmtui" }, center = true })

window_rule("gnome-settings-float", { match = { class = "org\\.gnome\\.Settings" }, float = true })
window_rule("gnome-settings-size", { match = { class = "org\\.gnome\\.Settings" }, size = "70% 80%" })
window_rule("gnome-settings-center", { match = { class = "org\\.gnome\\.Settings" }, center = true })

window_rule("pavucontrol-float", { match = { class = "org\\.pulseaudio\\.pavucontrol|yad-icon-browser" }, float = true })
window_rule("pavucontrol-size", { match = { class = "org\\.pulseaudio\\.pavucontrol|yad-icon-browser" }, size = "60% 70%" })
window_rule("pavucontrol-center", { match = { class = "org\\.pulseaudio\\.pavucontrol|yad-icon-browser" }, center = true })

window_rule("nwg-look-float", { match = { class = "nwg-look" }, float = true })
window_rule("nwg-look-size", { match = { class = "nwg-look" }, size = "50% 60%" })
window_rule("nwg-look-center", { match = { class = "nwg-look" }, center = true })

-- Special workspaces
window_rule("special-sysmon", { match = { class = "btop" }, workspace = "special:sysmon" })
window_rule("special-music-class", {
    match = { class = "feishin|Spotify|Supersonic|Cider|com.github.th_ch.youtube_music|Plexamp|com-maxrave-simpmusic-MainKt" },
    workspace = "special:music",
})
window_rule("special-music-spotify-title", {
    match = { initial_title = "Spotify( Free)?" },
    workspace = "special:music",
})
window_rule("special-communication", {
    match = { class = "discord|equibop|vesktop|whatsapp" },
    workspace = "special:communication",
})
window_rule("special-todo", { match = { class = "Todoist" }, workspace = "special:todo" })

-- Dialogs
for _, title in ipairs({
    "(Select|Open)( a)? (File|Folder)(s)?",
    "File (Operation|Upload)( Progress)?",
    ".* Properties",
    "Export Image as PNG",
    "GIMP Crash Debug",
    "Save As",
    "Library",
}) do
    local id = title:gsub("[^%w]+", "-")
    window_rule(("dialog-float-%s"):format(id), { match = { title = title }, float = true })
    window_rule(("dialog-center-%s"):format(id), { match = { title = title }, center = true })
end

local auth_title = "^(Authentication Required|Authenticate|Password Required|Sign In|Sign in|Login|Log in|Open URI|Open Link|External Protocol Request|Choose Application)$"
window_rule("small-auth-dialog-float", { match = { title = auth_title }, float = true })
window_rule("small-auth-dialog-center", { match = { title = auth_title }, center = true })
window_rule("small-auth-dialog-size", { match = { title = auth_title }, size = "45% 35%" })

local helper_title = "^(Error|Warning|Confirm|Confirmation|Question|Information)$"
window_rule("small-helper-dialog-float", { match = { title = helper_title }, float = true })
window_rule("small-helper-dialog-center", { match = { title = helper_title }, center = true })
window_rule("small-helper-dialog-size", { match = { title = helper_title }, size = "45% 35%" })

local pinentry_class = "^(pinentry|pinentry-gtk-2|pinentry-qt|org\\.gnome\\.Polkit|polkit-gnome-authentication-agent-1)$"
window_rule("pinentry-float", { match = { class = pinentry_class }, float = true })
window_rule("pinentry-center", { match = { class = pinentry_class }, center = true })
window_rule("pinentry-size", { match = { class = pinentry_class }, size = "38% 28%" })

-- Picture in picture (resize and move done via script)
local pip_title = "Picture(-| )in(-| )[Pp]icture"
window_rule("pip-initial-move", { match = { title = pip_title }, move = "100%-w-2% 100%-w-3%" })
window_rule("pip-keep-aspect", { match = { title = pip_title }, keep_aspect_ratio = true })
window_rule("pip-float", { match = { title = pip_title }, float = true })
window_rule("pip-pin", { match = { title = pip_title }, pin = true })

-- Creative software
window_rule("creative-opaque", {
    match = { class = "krita|gimp|inkscape|darktable|resolve|kdenlive|shotcut|blender|godot" },
    opaque = true,
})

-- Ueberzugpp
window_rule("ueberzugpp-float", { match = { class = "^(ueberzugpp_.*)$" }, float = true })
window_rule("ueberzugpp-no-initial-focus", { match = { class = "^(ueberzugpp_.*)$" }, no_initial_focus = true })

-- Steam
window_rule("steam-rounding", { match = { class = "steam" }, rounding = 10 })
window_rule("steam-friends-float", { match = { title = "Friends List", class = "steam" }, float = true })

-- Games (Steam, Lutris/Wine, Gamescope)
local game_class = "(steam_app_(default|[0-9]+))|gamescope"
window_rule("games-opaque", { match = { class = game_class }, opaque = true })
window_rule("games-immediate", { match = { class = game_class }, immediate = true })
window_rule("games-idle-inhibit", { match = { class = game_class }, idle_inhibit = "always" })

-- Minecraft launcher consoles
window_rule("atlauncher-console-float", {
    match = { class = "com-atlauncher-App", title = "ATLauncher Console" },
    float = true,
})
window_rule("pandora-console-float", {
    match = { class = "PandoraLauncher", title = "Minecraft Game Output" },
    float = true,
})

-- Autodesk Fusion 360
window_rule("fusion360-no-blur", {
    match = { title = "Fusion360|(Marking Menu)", class = "fusion360\\.exe" },
    no_blur = true,
})

-- XWayland popups
window_rule("xwayland-popup-no-dim", { match = { xwayland = true, title = "win[0-9]+" }, no_dim = true })
window_rule("xwayland-popup-no-shadow", { match = { xwayland = true, title = "win[0-9]+" }, no_shadow = true })
window_rule("xwayland-popup-rounding", { match = { xwayland = true, title = "win[0-9]+" }, rounding = 10 })

-- Workspace rules
hl.workspace_rule({
    workspace = "w[tv1]s[false]",
    gaps_out = values.singleWindowGapsOut,
    no_rounding = values.singleWindowRounding == 0,
})
hl.workspace_rule({
    workspace = "f[1]s[false]",
    gaps_out = values.singleWindowGapsOut,
    no_rounding = values.singleWindowRounding == 0,
})

-- Layer rules
layer_rule("hyprpicker-fade", { match = { namespace = "hyprpicker" }, animation = "fade" })
layer_rule("logout-dialog-fade", { match = { namespace = "logout_dialog" }, animation = "fade" })
layer_rule("selection-fade", { match = { namespace = "selection" }, animation = "fade" })
layer_rule("wayfreeze-fade", { match = { namespace = "wayfreeze" }, animation = "fade" })

-- Fuzzel
layer_rule("launcher-popin", { match = { namespace = "launcher" }, animation = "popin 80%" })
layer_rule("launcher-blur", { match = { namespace = "launcher" }, blur = true })

-- Shell
layer_rule("caelestia-border-area-no-anim", {
    match = { namespace = "caelestia-(border-exclusion|area-picker)" },
    no_anim = true,
})
layer_rule("caelestia-drawers-background-fade", {
    match = { namespace = "caelestia-(drawers|background)" },
    animation = "fade",
})
