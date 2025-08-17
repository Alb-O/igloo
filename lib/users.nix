# User profile definitions
# Keep personal information separate from system configuration
{
  # Default user profile - customize via environment or override
  default = rec {
    username = let u = builtins.getEnv "USERNAME"; in if u != "" then u else "user";
    name = let n = builtins.getEnv "NAME"; in if n != "" then n else "Default User";
    email = let e = builtins.getEnv "EMAIL"; in if e != "" then e else "user@localhost";
    homeDirectory = "/home/${username}";
  };

  # System/admin user for servers and WSL
  admin = {
    username = "admin";
    name = "System Administrator";  
    email = "admin@system.local";
    homeDirectory = "/home/admin";
  };
}