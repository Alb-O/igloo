# User profile definitions (pure, static)
{
  # Default user profile - edit to match your system user
  default = rec {
    username = "user";
    name = "Default User";
    email = "user@localhost";
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
