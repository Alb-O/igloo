# NixOS modules aggregation
{ host, ... }: {
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
      if host.isGraphical
      then [
        ./desktop.nix
      ]
      else []
    );

}
