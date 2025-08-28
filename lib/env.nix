# Single source of truth for environment variable loading
# Used by both system and home-manager configurations
let
  # Helper to get env var with fallback
  getEnv = key: fallback: let
    value = builtins.getEnv key;
  in
    if value != ""
    then value
    else fallback;

  # System detection
  isWSL =
    (builtins.getEnv "WSL_DISTRO_NAME") != ""
    || (builtins.getEnv "WSLENV") != ""
    || (builtins.getEnv "IS_WSL") == "true";

  # Machine type detection
  machineId = getEnv "MACHINE_ID" "desktop";
in {
  # User info
  username = getEnv "USERNAME" (getEnv "USER" "user");
  fullName = getEnv "NAME" (getEnv "FULL_NAME" "NixOS User");
  email = getEnv "EMAIL" "user@example.com";
  
  # System info
  hostname = getEnv "HOSTNAME" "nixos";
  inherit machineId isWSL;
  
  # Environment settings
  timezone = getEnv "TIMEZONE" "UTC";
  locale = getEnv "DEFAULT_LOCALE" "en_US.UTF-8";
  
  # Determine if graphical based on machine type and WSL status
  isGraphical = !isWSL && (machineId == "desktop" || machineId == "laptop");
}