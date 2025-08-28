# NixOS modules aggregation
{globals, ...}: {
  imports =
    [
      ./xdg.nix
      ./keyring.nix
      ./packages.nix
      ./keyboard.nix
      ./ssh.nix
      ./flake-configuration.nix
      ./wsl.nix
    ]
    ++ (
      # Only import desktop modules for graphical systems
      if globals.system.isGraphical
      then [
        ./desktop.nix
      ]
      else []
    );

  # Set environment variables for system-wide use
  environment.sessionVariables = {
    TIMEZONE = globals.env.timezone;
    DEFAULT_LOCALE = globals.env.locale;
    LC_LOCALE = globals.env.locale;
    HOSTNAME = globals.env.hostname;
    USERNAME = globals.env.username;
  };
}
