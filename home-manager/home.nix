# Home Manager configuration
# Main entry point for user environment configuration
{
  pkgs,
  lib,
  inputs,
  user,
  host,
  ...
}:
{
  # Import modular configuration
  imports = [
    # Custom modules
    ./modules

    # Example external modules (commented out):
    # outputs.homeManagerModules.example
    # inputs.nix-colors.homeManagerModules.default
  ];

  # Basic user information
  home = {
    username = user.username;
    homeDirectory = user.homeDirectory;
  };

  # User packages
  home.packages =
    with pkgs.unstable;
    [
      # CLI Tools (always included)
      gh
      unzip
      lm_sensors
      ffmpeg
      yt-dlp
      atuin
      unison
      rucola
      onefetch
      poppler-utils
      unipicker
      nodejs
      gcc
      gnumake
    ]
    ++ lib.optionals host.isGraphical [
      # Graphical Tools (only when isGraphical = true)
      hyprpicker
      vesktop
      xdg-desktop-portal-termfilechooser
      # Clipboard tools for Wayland
      wl-clipboard
      cliphist
      # Input configuration
      solaar
      libinput
    ];

  # State version - don't change this
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = host.stateVersion;

  programs.bash.enable = true;
  home.file.".config/bash/profile" = {
    source = ./dotfiles/bash/profile.sh;
  };

  programs.bash.profileExtra = ''
    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    if [ -r "$XDG_CONFIG_HOME/bash/profile" ]; then
      # shellcheck disable=SC1090
      . "$XDG_CONFIG_HOME/bash/profile"
    fi
  '';
}
