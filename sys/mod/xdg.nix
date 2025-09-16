{ pkgs, ... }:
{
  xdg.portal.enable = true;
  xdg.portal.configPackages = [ pkgs.xdg-desktop-portal-termfilechooser ];
  # XDG Base Directory support for NixOS
  # Enables XDG compliance for system-level Nix operations
  nix.settings.use-xdg-base-directories = true;

  # Environment variables for system-wide XDG compliance
  environment.sessionVariables = {
    # Ensure XDG directories are available system-wide
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
  };
}
