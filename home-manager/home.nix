# Home Manager configuration
# Main entry point for user environment configuration
{
  pkgs,
  lib,
  inputs,
  globals,
  ...
}:
{
  # Import modular configuration
  imports = [
    # Custom modules
    (import ./modules { inherit inputs globals; })

    # Example external modules (commented out):
    # outputs.homeManagerModules.example
    # inputs.nix-colors.homeManagerModules.default
  ];

  # Basic user information
  home = {
    username = globals.user.username;
    homeDirectory = globals.user.homeDirectory;
  };

  # User packages
  home.packages =
    with pkgs.unstable;
    [
      # CLI Tools (always included)
      jq
      fastfetch
      gh
      just
      opencode
      xdg-ninja
      lm_sensors
      ffmpeg
      yt-dlp
      ripgrep
      unison
      bat
      nb
      tree
      imagemagick
      poppler-utils
      # Development
      nodejs
      gcc
    ]
    ++ lib.optionals globals.system.isGraphical [
      # Graphical Tools (only when isGraphical = true)
      unipicker
      hyprpicker
      foot
      rucola
      hydrus
      ungoogled-chromium
      # Clipboard tools for Wayland
      wl-clipboard
      cliphist
    ]
    ++ [
      # Custom packages
      (pkgs.writeShellApplication {
        name = "codex";
        runtimeInputs = [ pkgs.nodejs ];
        text = ''
          exec ${pkgs.nodejs}/bin/npx -y @openai/codex "$@"
        '';
      })
    ]
    ++ lib.optionals globals.system.isGraphical [
      # Custom graphical packages
      pkgs.blender-daily
    ];

  # State version - don't change this
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = globals.system.stateVersion;

  # Ensure login shells source Home Manager session vars from XDG-friendly paths
  # and avoid legacy ~/.nix-profile references.
  # Manage the user's login profile explicitly. Rationale:
  # - Home Manager's genericLinux target historically generated a ~/.profile that
  #   sourced ~/.nix-profile/etc/profile.d/hm-session-vars.sh. With
  #   nix.settings.use-xdg-base-directories = true, the canonical per-user
  #   profile lives under $XDG_STATE_HOME/nix/profile (or /etc/profiles/per-user on NixOS).
  # - We force our own .profile here so shells stop referencing ~/.nix-profile and
  #   instead prefer XDG locations, falling back safely when needed.
  # - On NixOS, /etc/profiles/per-user/$USER is the stable canonical path for
  #   hm-session-vars. We try that first, then XDG STATE paths.
  # - If a legacy ~/.nix-profile exists, remove it or symlink it to
  #   $XDG_STATE_HOME/nix/profile to avoid warnings.
  home.file.".profile" = lib.mkForce {
    text = ''
      # Source system profile if present (NixOS sets this)
      if [ -e /etc/profile ]; then
        . /etc/profile
      fi

      # Prefer canonical per-user profile under /etc (NixOS),
      # then XDG paths as configured by use-xdg-base-directories.
      #
      # Order of preference:
      #  1) /etc/profiles/per-user/$USER/...  (canonical on NixOS)
       #  2) "$XDG_STATE_HOME"/nix/profile/...  (XDG-compliant user profile)
       #  3) "$HOME/.local/state"/nix/profile/...       (implicit XDG_STATE_HOME)
       #
       # Notes:
       # - We intentionally do NOT use ~/.nix-profile to avoid legacy paths.
       # - If a tool still references ~/.nix-profile, create a compat symlink:
       #     ln -sTf "$\{XDG_STATE_HOME}:-$HOME/.local/state}/nix/profile" "$HOME/.nix-profile"
       if [ -e "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
         . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
       elif [ -n "$XDG_STATE_HOME" ] && [ -e "$XDG_STATE_HOME/nix/profile/etc/profile.d/hm-session-vars.sh" ]; then
         . "$XDG_STATE_HOME/nix/profile/etc/profile.d/hm-session-vars.sh"
       elif [ -e "$HOME/.local/state/nix/profile/etc/profile.d/hm-session-vars.sh" ]; then
         . "$HOME/.local/state/nix/profile/etc/profile.d/hm-session-vars.sh"
       fi
    '';
    force = true;
  };
}
