# Global configuration for NixOS systems
{
  env,
  userProfile,
  hostProfile,
}: {
  # User information from profile
  user = userProfile;

  # System information from host profile
  system = hostProfile;

  # Environment from single source
  inherit env;

  # UI configuration
  ui = {
    isGraphical = env.isGraphical;
  };
}
