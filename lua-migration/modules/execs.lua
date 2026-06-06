local values = require("modules.values")

-- Equivalent of config/hypr/hyprland/execs.conf.
hl.on("hyprland.start", function()
    -- Keyring and auth
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Clipboard history
    -- Text clipboard history is enabled for Super+V.
    -- Image history stays disabled so screenshots do not clutter the picker.
    hl.exec_cmd("~/.config/hypr/scripts/cliphist-text-only.sh")
    -- hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto delete trash 30 days old
    hl.exec_cmd("trash-empty 30")

    -- Cursors
    hl.exec_cmd(("hyprctl setcursor %s %s"):format(values.cursorTheme, values.cursorSize))
    hl.exec_cmd(("gsettings set org.gnome.desktop.interface cursor-theme '%s'"):format(values.cursorTheme))
    hl.exec_cmd(("gsettings set org.gnome.desktop.interface cursor-size %s"):format(values.cursorSize))

    -- Location provider and night light
    -- Disabled for privacy and battery: no background geolocation or colour-temp daemon by default.
    -- Re-enable if you want automatic night light based on location.
    -- hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent")
    -- hl.exec_cmd("sleep 1 && gammastep")

    -- Forward bluetooth media commands to MPRIS
    hl.exec_cmd("mpris-proxy")

    -- Resize and move windows based on matches (e.g. pip)
    hl.exec_cmd("caelestia resizer -d")

    -- Start shell
    hl.exec_cmd("caelestia shell -d")
end)
