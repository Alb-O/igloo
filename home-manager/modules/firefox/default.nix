# Firefox configuration - modularized
{ lib, pkgs, user, ... }: let
  # Import modular configurations
  policiesConfig = import ./policies.nix {};
  extensionsConfig = import ./extensions.nix {};
  profileConfig = import ./profile.nix {inherit lib;};
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
