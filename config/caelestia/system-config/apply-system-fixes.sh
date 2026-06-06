#!/usr/bin/env bash
set -euo pipefail

USER_HOME="${SUDO_USER:+/home/$SUDO_USER}"
USER_HOME="${USER_HOME:-$HOME}"

echo "Cleaning pacman cache, keeping the latest 2 versions..."
paccache -rk2 || true

echo "Vacuuming journal logs to 200M..."
journalctl --vacuum-size=200M || true

echo "Installing safer UPower low-battery fallback..."
install -m 0644 "$USER_HOME/.config/caelestia/system-config/90-low-battery-safe.conf" /etc/UPower/UPower.conf.d/90-low-battery-safe.conf
systemctl restart upower.service

echo "Enabling weekly SSD trim..."
systemctl enable --now fstrim.timer

echo "Done."
df -h /
