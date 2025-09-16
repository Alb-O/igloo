# Notes

Rundown of this NixOS setup's quirks:

## Flake Structure
- Root flake drives both NixOS and Home Manager
- Default user/host values live in `flake.nix`; override them in `overrides/personal.nix`
- Resulting Home Manager target name is `username@hostname`
- Home Manager activation requires the configured username to match the real user; keep your override in sync before switching
- Use `just` commands, not raw nix/nixos-rebuild
- Pure evaluation: no `--impure`, no `.env` sourcing

## Environment Variables
- No eval-time env access; select hosts/users via flake attrs
- User/host passed directly via specialArgs

## Graphical vs Non-Graphical
- `desktopHost` sets `isGraphical = true`, `serverHost` leaves it false
- Home-manager packages split between CLI tools (always) and GUI tools (conditional)
- Modules auto-import different sets based on this flag

## Home Manager
- Integrated via the root flake
- Uses user@hostname format for configs
- Session vars managed via XDG paths, no legacy ~/.nix-profile

## Host Profiles
- `desktop` = full graphical system (defined in `flake.nix`, override via `overrides/personal.nix`)
- `server` = WSL/headless, graphical services disabled (overrideable as above)
- Both hosts reuse the same user profile data from the override/defaults

## Build Commands
```bash
just system-rebuild                # NixOS system (desktop by default)
just system-rebuild server         # NixOS server/WSL
just home-switch                   # Home Manager user env (target inferred)
just check-all                     # Validate flake
```
