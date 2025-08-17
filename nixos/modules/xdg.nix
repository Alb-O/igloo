{
  # XDG Base Directory support for NixOS
  # Enables XDG compliance for system-level Nix operations

  # Disable XDG base directories for nix commands to use traditional ~/.nix-profile
  nix.settings.use-xdg-base-directories = false;

  # Environment variables for system-wide XDG compliance
  environment.sessionVariables = {
    # Ensure XDG directories are available system-wide
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
  };
}
