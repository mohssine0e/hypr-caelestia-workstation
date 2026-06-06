# Hypr Caelestia Workstation Tasks

## AI Work Rules

- Work feature by feature.
- Check git status before editing.
- Make small changes.
- Verify after each change.
- Show diff before commit.
- Commit only working changes.
- Push only after verification.
- Never overwrite working user customizations.
- Never replace this setup with stock End-4 or stock Caelestia.

## Phase 1 - Repository Safety

- [ ] Map active config files
- [ ] Identify old backups and unused files
- [ ] Confirm no secrets/private runtime files are tracked
- [ ] Create first clean commit

## Phase 2 - Hyprland Lua Migration

- [ ] Inventory current `.conf` modules
- [ ] Map variables to Lua
- [ ] Map keybinds to Lua
- [ ] Map window rules to Lua
- [ ] Map exec/startup rules to Lua
- [ ] Map input and gestures to Lua
- [ ] Create `hyprland.lua` beside existing config
- [ ] Test Lua config safely
- [ ] Switch only when behavior matches current setup

## Phase 3 - Caelestia / Quickshell

- [ ] Preserve dashboard behavior
- [ ] Preserve Timebox behavior
- [ ] Preserve Todos behavior
- [ ] Preserve sidebar/notifications
- [ ] Preserve workspace indicators
- [ ] Remove unused QML only after reference checks

## Phase 4 - Laptop Stability

- [ ] Verify battery behavior
- [ ] Verify lock screen
- [ ] Verify screen recording
- [ ] Verify Bluetooth/audio
- [ ] Verify screenshots/clipboard
- [ ] Verify suspend/hibernate

## Phase 5 - Documentation

- [ ] Document active paths
- [ ] Document keybinds
- [ ] Document update procedure
- [ ] Document rollback procedure
