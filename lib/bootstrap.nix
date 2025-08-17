# Minimal bootstrap configuration for NixOS
# Provides environment variable defaults
{
  env = {
    # Default environment variables with fallbacks
    USERNAME = builtins.getEnv "USERNAME";
    NAME = if (builtins.getEnv "NAME") != "" then (builtins.getEnv "NAME") else "NixOS User";
    EMAIL = if (builtins.getEnv "EMAIL") != "" then (builtins.getEnv "EMAIL") else "user@example.com";
    HOSTNAME = if (builtins.getEnv "HOSTNAME") != "" then (builtins.getEnv "HOSTNAME") else "nixos";
    MACHINE_ID = if (builtins.getEnv "MACHINE_ID") != "" then (builtins.getEnv "MACHINE_ID") else "nixos";
  };
}