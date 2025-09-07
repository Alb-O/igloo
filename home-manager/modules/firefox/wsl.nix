# Firefox configuration for WSL - headless/configuration-only setup
{ lib, user, config, ... }: let
  # Import modular configurations (same as main firefox module)
  policiesConfig = import ./policies.nix {};
  extensionsConfig = import ./extensions.nix {};
  # Resolve absolute download directory from XDG user dirs
  homeDir = config.home.homeDirectory;
  desktopDir = lib.replaceStrings ["$HOME"] [homeDir] config.xdg.userDirs.desktop;
  downloadDir = lib.replaceStrings ["$HOME" "$XDG_DESKTOP_DIR"] [homeDir desktopDir] config.xdg.userDirs.download;
  profileConfig = import ./profile.nix { inherit lib downloadDir; };
in {
  programs.firefox = {
    enable = true;

    # Security and extension policies (same as full configuration)
    policies =
      policiesConfig.policies
      // {
        ExtensionSettings = extensionsConfig.extensionSettings;
      };

    # User profile configuration
    profiles.${user.username} = {
      id = 0;
      isDefault = true;
      path = user.username; # Explicitly set profile path

      # Profile settings
      settings = profileConfig.profileSettings;

      # Note: userContent and userChrome are disabled for WSL
      # as they require GUI-specific theming that's not needed for config sync
    };
  };

  # Note: No MIME associations or session variables for WSL
  # These are GUI-specific and not needed for headless Firefox config
}
