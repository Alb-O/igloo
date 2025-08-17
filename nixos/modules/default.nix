# NixOS modules aggregation
{globals, ...}: {
  imports =
    [
      ./xdg.nix
      ./keyring.nix
      ./packages.nix
      ./keyboard.nix
      ./fonts.nix
      ./ssh.nix
      ./flake-configuration.nix
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
  environment.sessionVariables = globals.env or {};
}
