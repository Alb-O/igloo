# Notes

Rundown of this NixOS setup's quirks:

## Flake Structure
- Separate flakes: root for NixOS system configs, `home-manager/` for user configs
- Use `just` commands, not raw nix/nixos-rebuild
- Everything uses `--impure` because we load env vars

## Environment Variables
- `.env` files get sourced and passed through
- Host profiles determined by `HOSTNAME` env var
- Uses impure evaluation everywhere for env var access
- `globals.nix` merges env vars with host/user profiles

## Graphical vs Non-Graphical
- `isGraphical` flag controls what gets built
- Desktop profile = graphical, Server profile = headless/WSL
- Home-manager packages split between CLI tools (always) and GUI tools (conditional)
- Modules auto-import different sets based on this flag

## Home Manager
- Standalone, not integrated with NixOS
- Lives in separate `home-manager/` directory with own flake
- Uses user@hostname format for configs
- Session vars managed via XDG paths, no legacy ~/.nix-profile

## Host Profiles
- `desktop` = full graphical system
- `server` = WSL/headless, graphical services disabled
- Profiles live in `lib/hosts.nix`, referenced everywhere

## Build Commands
```bash
just system-rebuild        # NixOS system
just home-switch           # Home Manager user env
just check-all             # Validate both flakes
```
