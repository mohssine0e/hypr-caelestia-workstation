# Hyprland Lua Migration

This directory contains inactive Hyprland Lua migration work. It is intentionally
kept inside the repository and outside the active `~/.config/hypr/hyprland.lua`
path until the full Lua config is verified and manually approved.

## Safety Model

- Keep the current `.conf` graph as the source of truth until the Lua graph
  matches behavior.
- Migrate one module at a time, using the existing files under `config/hypr`
  and `config/caelestia` as input.
- Verify every slice with `Hyprland --verify-config --config <test-file>`.
- Commit only verified slices.
- Do not activate Lua automatically.

## Layout

```text
lua-migration/
├── README.md
├── test-*.lua          # inactive verification entrypoints
└── modules/
    ├── values.lua      # active merged values from variables.conf + overrides
    └── *.lua           # module-by-module Lua equivalents
```

The final inactive full entrypoint will be `lua-migration/hyprland.lua`.

## Verification

Run a slice verification from the repository root:

```sh
Hyprland --verify-config --config ./lua-migration/test-input.lua
```

Run final verification after all modules are present:

```sh
Hyprland --verify-config --config ./lua-migration/hyprland.lua
```

Manual activation, when approved, should copy or symlink the final verified
entrypoint into the active Hyprland config path. Do not do this during slice
migration.
