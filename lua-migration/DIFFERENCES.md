# Lua Migration Differences

The inactive Lua graph verifies on local Hyprland 0.55.2, but these differences
need live-session review before activation.

## Known Differences

- `SUPER + catchall` from `bindin = Super, catchall, global,
  caelestia:launcherInterrupt` is omitted. Hyprland Lua 0.55.2 rejected the
  modifier-scoped catchall key string during verification. It was not replaced
  with an unmodified `catchall` because that would be much broader than the
  current binding.
- Theme and variable values in `modules/values.lua` are the active merged values
  from the current snapshot. The Lua graph does not yet dynamically parse
  `scheme/current.conf`, `variables.conf`, or `hypr-vars.conf`.
- `exec-once` entries are represented with a `hyprland.start` callback in
  `modules/execs.lua`, matching startup-only intent while keeping verification
  from running those commands.
- Workspace smart-gap `rounding:0` is represented as Lua `no_rounding = true`,
  because Hyprland Lua workspace rules rejected a numeric `rounding` field.

## Activation Status

Not active. No `~/.config/hypr/hyprland.lua` has been created.
