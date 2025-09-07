# Firefox configuration - modularized
{ lib, pkgs, user, config, ... }: let
  # Import modular configurations
  policiesConfig = import ./policies.nix {};
  extensionsConfig = import ./extensions.nix {};
  # Resolve absolute download directory from XDG user dirs
  homeDir = config.home.homeDirectory;
  desktopDir = lib.replaceStrings ["$HOME"] [homeDir] config.xdg.userDirs.desktop;
  downloadDir = lib.replaceStrings ["$HOME" "$XDG_DESKTOP_DIR"] [homeDir desktopDir] config.xdg.userDirs.download;
  profileConfig = import ./profile.nix { inherit lib downloadDir; };
  searchConfig = import ./search.nix {inherit lib pkgs;};
in {
  programs.firefox = {
    enable = true;

    # Security and extension policies
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

      # Search engine configuration
      search = searchConfig.searchConfig;
    };
  };

  # MIME type associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = ["firefox.desktop"];
      "text/xml" = ["firefox.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "x-scheme-handler/about" = ["firefox.desktop"];
      "x-scheme-handler/unknown" = ["firefox.desktop"];
    };
  };

  home.sessionVariables = {
    # Electron apps use this variable to determine the default browser
    "DEFAULT_BROWSER" = "${pkgs.firefox}/bin/firefox";
  };
}
