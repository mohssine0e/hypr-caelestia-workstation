# Mohssine's Caelestia / Hyprland Setup

This setup is based on Caelestia dotfiles, with local custom changes for an HP EliteBook 840 G7 laptop running Arch Linux and Hyprland.

The goal of this setup is:

- productivity first
- good laptop battery life
- clean Catppuccin-style visuals
- keyboard and touchpad workflow
- privacy-conscious defaults

## Main Config Locations

### User Overrides

These are the safest files to edit. They are yours.

```text
~/.config/caelestia/
├── hypr-vars.conf   # Hyprland variables: gaps, blur, shadows, gestures, visual tuning
├── hypr-user.conf   # Extra Hyprland rules/gestures that load after Caelestia defaults
├── shell.json       # Caelestia/Quickshell UI settings
└── monitors/        # Monitor-specific overrides
```

Edit these first when you want to change behavior.

### Hyprland Config

```text
~/.config/hypr -> ~/.local/share/caelestia/hypr
```

Important: `~/.config/hypr` is a symlink to Caelestia's managed Hyprland config.

That means most files here are Caelestia base files:

```text
~/.config/hypr/hyprland.conf
~/.config/hypr/hyprland/input.conf
~/.config/hypr/hyprland/keybinds.conf
~/.config/hypr/hyprland/gestures.conf
~/.config/hypr/hyprland/execs.conf
~/.config/hypr/hyprland/rules.conf
```

You can edit them, but updates may overwrite or regenerate some content. Prefer `~/.config/caelestia/hypr-vars.conf` and `~/.config/caelestia/hypr-user.conf` when possible.

### Quickshell / Caelestia Shell

```text
~/.config/quickshell/caelestia/
├── shell.qml
├── modules/
├── components/
├── services/
└── utils/
```

This is the local Quickshell UI. It controls the bar, launcher, dashboard, lock screen, notifications, utilities, and custom Todo tab.

## Custom Changes Added

### Hyprland

File:

```text
~/.config/caelestia/hypr-user.conf
```

Current custom behavior:

- 3-finger swipe left/right/up/down moves the active tiled window.
- Window borders can be grabbed for resizing.

4-finger swipe up was tested for launcher, but removed because the touchpad/libinput/Hyprland gesture path did not trigger it reliably on this laptop.

### Hyprland Variables

File:

```text
~/.config/caelestia/hypr-vars.conf
```

Current custom behavior:

- 4-finger horizontal swipe switches workspaces.
- 3-finger gestures are reserved for moving windows.
- tight window gaps for more usable screen space
- battery-friendly visuals:
  - smaller blur
  - one blur pass
  - popup blur disabled
  - shadows disabled
  - full window opacity

### Keyboard Layouts

File:

```text
~/.config/hypr/hyprland/input.conf
```

Current layouts:

```conf
kb_layout = us,fr,ara
kb_options = grp:win_space_toggle
```

Use `Super + Space` to cycle between English, French, and Arabic.

### Shortcut Reference

File:

```text
~/.config/hypr/hyprland/keybinds.conf
```

Important shortcuts:

```text
Super                         Launcher
Super + L                     Lock screen
Ctrl + Alt + Delete           Session / power menu
Super + T                     Terminal
Super + B                     Browser
Super + C                     Code editor
Super + E                     File manager
Super + Q                     Close focused window
Super + F                     Fullscreen focused window
Super + P                     Display mode switcher
Super + Alt + P               Pin focused window
Super + Arrow                 Focus window in that direction
Super + Shift + Arrow         Move focused window in that direction
Super + Mouse left drag       Move floating/tiled window
Super + Mouse right drag      Resize window
Super + Minus / Equal         Resize window width
Super + Shift + Minus / Equal Resize window height
Super + 1..0                  Go to workspace 1..10
Super + Alt + 1..0            Move window to workspace 1..10
Ctrl + Super + Left/Right     Previous/next workspace
Super + PageUp/PageDown       Previous/next workspace
Super + R                     Todo special workspace
Super + M                     Music special workspace
Super + N                     Sidebar
Super + K                     Show shell panels
Super + V                     Clipboard picker
Super + Period                Emoji picker
Print                         Screenshot full screen
Super + Shift + S             Screenshot region
Super + End                   Play/pause media
```

### Privacy Hardening

File:

```text
~/.config/hypr/hyprland/execs.conf
```

Disabled:

- persistent clipboard history watchers
- Geoclue location agent
- automatic `gammastep` night-light daemon

Reason: these are convenient, but clipboard history can store secrets and Geoclue exposes location access.

### Lock Screen Privacy

File:

```text
~/.config/quickshell/caelestia/modules/lock/LockSurface.qml
```

Changed the lock screen so it no longer uses a live blurred screenshot of the desktop. It now uses an opaque lock background, so open windows are not visible behind the password prompt.

File:

```text
~/.config/caelestia/shell.json
```

Lock notifications are hidden:

```json
"lock": {
    "hideNotifs": true
}
```

The lock screen also keeps the layout intentionally minimal:

- clock and password/fingerprint unlock
- keyboard layout indicator for English/French/Arabic
- battery percentage
- no weather
- no notification list
- no app content from the desktop

### Power Management

File:

```text
~/.config/quickshell/caelestia/modules/AutoPowerProfile.qml
```

Current behavior:

- charging or fully charged: `performance`
- on battery above 40%: `balanced`
- on battery at or below 40%: `power-saver`
- Hyprland animations become slightly calmer on battery
- Hyprland animations return to the normal smoother profile when plugged in

This uses `power-profiles-daemon`.

Top bar battery indicators:

```text
SAVE  battery is under 30% and the laptop is on battery
20    battery is under 20%; the icon pulses red
PERF  charger is connected and performance mode is active
```

Low-battery protection:

```text
15%   Caelestia shows a low-battery warning
10%   Caelestia shows a critical warning
7%    Caelestia suspends the laptop; plug in before waking
5%    Recommended UPower system fallback cleanly powers off if the shell is not running
2%    Old UPower default; this is too late and can feel like a hard power cut
```

The Caelestia user-session protection is active in:

```text
~/.config/quickshell/caelestia/modules/BatteryMonitor.qml
```

For a system-level fallback that still works if the shell crashes, install this prepared UPower override:

```bash
sudo ~/.config/caelestia/system-config/apply-system-fixes.sh
```

Check current profile:

```bash
powerprofilesctl get
```

List available profiles:

```bash
powerprofilesctl list
```

### Todo Dashboard

File:

```text
~/.config/quickshell/caelestia/modules/dashboard/TodoTab.qml
```

Custom Todo tab features:

- add tasks
- add subtasks
- parent task completes automatically when subtasks are complete
- progress bar for tasks with subtasks
- only one task expands at a time
- edit parent tasks
- edit subtasks
- delete tasks/subtasks
- persistent storage

Todo data is stored at:

```text
~/.local/state/caelestia/todos.json
```

### Pomodoro Timer

Files:

```text
~/.config/quickshell/caelestia/shell.qml
~/.config/quickshell/caelestia/services/PomodoroTimer.qml
~/.config/quickshell/caelestia/modules/dashboard/Content.qml
~/.config/quickshell/caelestia/modules/dashboard/PomodoroTab.qml
~/.config/quickshell/caelestia/modules/bar/components/StatusIcons.qml
~/.config/quickshell/caelestia/modules/bar/popouts/Pomodoro.qml
~/.config/quickshell/caelestia/modules/bar/popouts/Content.qml
```

Current behavior:

- Pomodoro tab inside the dashboard
- small timer icon in the bar status area
- hover/click the icon to open controls
- start/pause, reset, and skip
- focus, short break, and long break modes
- default cycle: 25 min focus, 5 min break, 15 min long break every 4 focus rounds

To change durations, edit:

```qml
readonly property int workMinutes: 25
readonly property int shortBreakMinutes: 5
readonly property int longBreakMinutes: 15
readonly property int longBreakEvery: 4
```

## Common Commands

Reload Hyprland:

```bash
hyprctl reload
```

Restart Caelestia shell:

```bash
qs -c caelestia kill
caelestia shell -d
```

Validate Hyprland config:

```bash
Hyprland --verify-config --config ~/.config/hypr/hyprland.conf
```

List running Quickshell instances:

```bash
qs list -a --json
```

Check input devices and keyboard layouts:

```bash
hyprctl devices
```

Check battery info:

```bash
upower -i /org/freedesktop/UPower/devices/battery_BAT0
```

## Updating Caelestia

Before updating, back up local custom files:

```bash
cp -a ~/.config/caelestia ~/.config/caelestia.backup.$(date +%Y%m%d-%H%M%S)
cp -a ~/.config/quickshell/caelestia ~/.config/quickshell/caelestia.backup.$(date +%Y%m%d-%H%M%S)
```

After updating:

1. Check whether `~/.config/hypr` still points to Caelestia:

```bash
ls -la ~/.config/hypr
```

2. Re-apply or compare custom files:

```bash
diff -ru ~/.config/caelestia.backup.YYYYMMDD-HHMMSS ~/.config/caelestia
```

3. Validate Hyprland:

```bash
Hyprland --verify-config --config ~/.config/hypr/hyprland.conf
```

4. Restart Hyprland shell pieces:

```bash
hyprctl reload  # to reload Hyprland with new config
qs -c caelestia kill  # to stop the old shell
caelestia shell -d   # to start a fresh shell with the new config
```

## What To Edit For Common Changes

Window gaps:

```text
~/.config/caelestia/hypr-vars.conf
```

Look for:

```conf
$windowGapsIn
$windowGapsOut
$singleWindowGapsOut
$workspaceGaps
```

Blur/shadows/performance:

```text
~/.config/caelestia/hypr-vars.conf
```

Look for:

```conf
$blurEnabled
$blurSize
$blurPasses
$shadowEnabled
$windowOpacity
```

Custom gestures:

```text
~/.config/caelestia/hypr-user.conf
```

Keyboard layout:

```text
~/.config/hypr/hyprland/input.conf
```

Startup apps:

```text
~/.config/hypr/hyprland/execs.conf
```

Dashboard Todo tab:

```text
~/.config/quickshell/caelestia/modules/dashboard/TodoTab.qml
```

Pomodoro timer:

```text
~/.config/quickshell/caelestia/shell.qml
~/.config/quickshell/caelestia/services/PomodoroTimer.qml
~/.config/quickshell/caelestia/modules/dashboard/PomodoroTab.qml
~/.config/quickshell/caelestia/modules/bar/popouts/Pomodoro.qml
```

Lock screen:

```text
~/.config/quickshell/caelestia/modules/lock/LockSurface.qml
~/.config/quickshell/caelestia/modules/lock/Content.qml
~/.config/quickshell/caelestia/modules/lock/Resources.qml
```

Power profile logic:

```text
~/.config/quickshell/caelestia/modules/AutoPowerProfile.qml
```

## Battery Notes For HP EliteBook 840 G7

Your battery health was observed around 73% of design capacity with about 697 cycles.

That means:

- battery drain is not only a config issue
- browser tabs, VS Code, video playback, and high CPU tasks matter a lot
- `performance` mode while charging is fine
- `balanced` on battery is reasonable
- `power-saver` at 40% helps extend runtime

For maximum battery life on a long unplugged session, manually switch to:

```bash
powerprofilesctl set power-saver
```

Return to balanced:

```bash
powerprofilesctl set balanced
```

## Known Tradeoffs

- Clipboard history is disabled for privacy. Re-enable it in `execs.conf` only if you accept the risk.
- Geolocation/night-light is disabled. Use manual screen temperature tools if needed.
- 4-finger up launcher gesture was removed because it did not work reliably on this touchpad.
- `tlp.service` exists on the system but was inactive. Disabling it fully needs sudo:

```bash
sudo systemctl disable --now tlp.service
```

Use either `power-profiles-daemon` or TLP, not both.

## Suggestions To Keep This Setup Healthy

- Keep the dashboard simple. Put deep information in Performance, Todos, and Pomodoro instead of adding more dashboard boxes.
- Do not enable clipboard history unless you really need it; it can store passwords, tokens, and private messages.
- Keep `power-profiles-daemon` as the single power manager unless you intentionally switch to TLP.
- Use `Super + Space` before typing a password if the lock screen layout indicator shows the wrong language.
- After Caelestia updates, compare your backup before accepting changed lock/dashboard/bar files.
- For study sessions, use Pomodoro plus power-saver mode when unplugged; video playback and many browser tabs still dominate battery drain.

## Fingerprint Unlock

Your fingerprint reader appears as:

```text
06cb:00df Synaptics
```

The lock screen is configured to try fingerprint unlock, but the system package is required:

```bash
sudo pacman -S --needed fprintd
fprintd-enroll
fprintd-verify
```

After enrollment, restart Caelestia:

```bash
qs -c caelestia kill
caelestia shell -d
```
