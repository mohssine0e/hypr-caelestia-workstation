#!/usr/bin/env bash
set -euo pipefail

# GNOME Settings intentionally refuses to start outside GNOME/Unity.
# Spoof only this process so Hyprland still exposes itself normally elsewhere.
export XDG_CURRENT_DESKTOP=GNOME
export XDG_SESSION_DESKTOP=gnome

exec gnome-control-center "$@"
