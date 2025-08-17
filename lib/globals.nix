# Global configuration for NixOS systems
# Now uses user and host profiles for better abstraction
{
  userProfile,
  hostProfile,
}: {
  # User information from profile
  user = userProfile;

  # System information from host profile
  system = hostProfile;

  # Environment defaults (can be overridden via environment variables)
  env = {
    TIMEZONE = let tz = builtins.getEnv "TIMEZONE"; in if tz != "" then tz else "UTC";
    DEFAULT_LOCALE = let locale = builtins.getEnv "DEFAULT_LOCALE"; in if locale != "" then locale else "en_US.UTF-8";
    LC_LOCALE = let locale = builtins.getEnv "LC_LOCALE"; in if locale != "" then locale else "en_US.UTF-8";
  };

  # UI configuration
  ui = {
    isGraphical = hostProfile.isGraphical;
  };
}