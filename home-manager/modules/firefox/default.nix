# Firefox configuration - modularized
{
  lib,
  #inputs,
  #pkgs,
  globals,
  ...
}:
let
  # Import modular configurations
  #colorschemeConfig = import ./colorscheme.nix {inherit inputs pkgs;};
  #userChromeConfig = import ./userchrome.nix {};
  policiesConfig = import ./policies.nix { };
  extensionsConfig = import ./extensions.nix { };
  profileConfig = import ./profile.nix { inherit lib; };
in
{
  programs.firefox = {
    enable = true;

    # Security and extension policies
    policies = policiesConfig.policies // {
      ExtensionSettings = extensionsConfig.extensionSettings;
    };

    # User profile configuration
    profiles.${globals.user.username} = {
      id = 0;
      isDefault = true;
      path = globals.user.username; # Explicitly set profile path

      # Profile settings
      settings = profileConfig.profileSettings;

      # Apply generated userstyles and userChrome theme - DISABLED
      #userContent = colorschemeConfig.userStyles;
      #userChrome = userChromeConfig.userChromeCSS;
    };
  };

  # MIME type associations
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };

  home.sessionVariables = {
    # Some programs rely on this variable to determine the default browser
    "BROWSER" = "firefox";
  };
}
