# Dynamic environment loader for Home Manager
# Loads personal information from environment variables
let
  # Helper to get env var with fallback
  getEnv = key: fallback: 
    let value = builtins.getEnv key;
    in if value != "" then value else fallback;

  # Detect if running in WSL using environment variables or explicit flag
  isWSL = (builtins.getEnv "WSL_DISTRO_NAME") != "" || 
          (builtins.getEnv "WSLENV") != "" ||
          (builtins.getEnv "IS_WSL") == "true";

in {
  # Personal information (from .env file or environment)
  username = getEnv "USERNAME" (getEnv "USER" "user");
  fullName = getEnv "NAME" (getEnv "FULL_NAME" "Home Manager User");
  email = getEnv "EMAIL" "user@example.com";
  hostname = getEnv "HOSTNAME" "localhost";
  
  # System detection
  inherit isWSL;
}