#!/usr/bin/env bash
set -euo pipefail

notify() {
    notify-send -a "display-menu" "$1" "${2:-}" 2>/dev/null || true
}

monitors_json="$(hyprctl monitors all -j)"
laptop="$(jq -r 'map(select(.name | test("^(eDP|LVDS)")))[0].name // .[0].name // empty' <<<"$monitors_json")"

if [[ -z "$laptop" ]]; then
    notify "No display detected" "Hyprland did not report any monitor."
    exit 1
fi

mapfile -t externals < <(jq -r --arg laptop "$laptop" '.[] | select(.name != $laptop) | .name' <<<"$monitors_json")

if (( ${#externals[@]} == 0 )); then
    choice="$(printf '%s\n' "Open GNOME Displays" "Cancel" | wofi --dmenu --prompt "Displays" --width 360 --height 140 || true)"
    if [[ "$choice" == "Open GNOME Displays" ]]; then
        app2unit -- "$HOME/.config/caelestia/scripts/gnome-settings.sh" display >/dev/null 2>&1 &
    else
        notify "No external display" "Connect HDMI/USB-C first, then press Super+P again."
    fi
    exit 0
fi

choice="$(printf '%s\n' \
    "Duplicate / Mirror" \
    "Extend right" \
    "Laptop only" \
    "External only" \
    "Open GNOME Displays" \
    "Cancel" |
    wofi --dmenu --prompt "Displays" --width 420 --height 260 || true)"

[[ -z "$choice" || "$choice" == "Cancel" ]] && exit 0

laptop_width="$(jq -r --arg laptop "$laptop" '.[] | select(.name == $laptop) | .width // 1920' <<<"$monitors_json")"
offset="$laptop_width"

case "$choice" in
    "Duplicate / Mirror")
        hyprctl keyword monitor "$laptop,preferred,0x0,1"
        for external in "${externals[@]}"; do
            hyprctl keyword monitor "$external,preferred,0x0,1,mirror,$laptop"
        done
        notify "Displays mirrored" "External display mirrors $laptop."
        ;;
    "Extend right")
        hyprctl keyword monitor "$laptop,preferred,0x0,1"
        for external in "${externals[@]}"; do
            hyprctl keyword monitor "$external,preferred,${offset}x0,1"
            ext_width="$(jq -r --arg external "$external" '.[] | select(.name == $external) | .width // 1920' <<<"$monitors_json")"
            offset=$((offset + ext_width))
        done
        notify "Displays extended" "External display is placed to the right."
        ;;
    "Laptop only")
        hyprctl keyword monitor "$laptop,preferred,0x0,1"
        for external in "${externals[@]}"; do
            hyprctl keyword monitor "$external,disable"
        done
        notify "Laptop display only" "$laptop is active."
        ;;
    "External only")
        offset=0
        for external in "${externals[@]}"; do
            hyprctl keyword monitor "$external,preferred,${offset}x0,1"
            ext_width="$(jq -r --arg external "$external" '.[] | select(.name == $external) | .width // 1920' <<<"$monitors_json")"
            offset=$((offset + ext_width))
        done
        hyprctl keyword monitor "$laptop,disable"
        notify "External display only" "Laptop panel disabled."
        ;;
    "Open GNOME Displays")
        app2unit -- "$HOME/.config/caelestia/scripts/gnome-settings.sh" display >/dev/null 2>&1 &
        ;;
esac
