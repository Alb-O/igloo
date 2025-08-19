# Firefox configuration for WSL - headless/configuration-only setup
{
  lib,
  globals,
  ...
}: let
  # Import modular configurations (same as main firefox module)
  policiesConfig = import ./policies.nix {};
  extensionsConfig = import ./extensions.nix {};
  profileConfig = import ./profile.nix {inherit lib;};
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
    profiles.${globals.user.username} = {
      id = 0;
      isDefault = true;
      path = globals.user.username; # Explicitly set profile path

      # Profile settings
      settings = profileConfig.profileSettings;

      # Note: userContent and userChrome are disabled for WSL
      # as they require GUI-specific theming that's not needed for config sync
    };
  };

  # Note: No MIME associations or session variables for WSL
  # These are GUI-specific and not needed for headless Firefox config
}
