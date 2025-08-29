# Notes

Rundown of this NixOS setup's quirks:

## Flake Structure
- Separate flakes: root for NixOS system configs, `home-manager/` for user configs
- Use `just` commands, not raw nix/nixos-rebuild
- Pure evaluation: no `--impure`, no `.env` sourcing

## Environment Variables
- No eval-time env access; select hosts/users via flake attrs
- User/host passed directly via specialArgs

## Graphical vs Non-Graphical
- `isGraphical` flag lives in host profile
- Desktop profile = graphical, Server profile = headless/WSL
- Home-manager packages split between CLI tools (always) and GUI tools (conditional)
- Modules auto-import different sets based on this flag

## Home Manager
- Integrated via the root flake
- Uses user@hostname format for configs
- Session vars managed via XDG paths, no legacy ~/.nix-profile

## Host Profiles
- `desktop` = full graphical system
- `server` = WSL/headless, graphical services disabled
- Profiles live in `lib/hosts.nix`, referenced everywhere

## Build Commands
```bash
just system-rebuild                # NixOS system (desktop by default)
just system-rebuild server         # NixOS server/WSL
just home-switch default@desktop   # Home Manager user env
just check-all                     # Validate flake
```
