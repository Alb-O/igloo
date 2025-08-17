# Dynamic environment loader for Home Manager
# Loads personal information from environment variables
let
  # Helper to get env var with fallback
  getEnv = key: fallback: 
    let value = builtins.getEnv key;
    in if value != "" then value else fallback;

in {
  # Personal information (from .env file or environment)
  username = getEnv "USERNAME" (getEnv "USER" "user");
  fullName = getEnv "FULL_NAME" "Home Manager User";
  email = getEnv "EMAIL" "user@example.com";
  hostname = getEnv "HOSTNAME" "localhost";
}