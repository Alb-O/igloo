# NixOS modules aggregation
{ host, ... }:
{
  imports = [
    ./fonts.nix
    ./xdg.nix
    ./keyring.nix
    ./packages.nix
    ./keyboard.nix
    ./ssh.nix
    ./flake-configuration.nix
    ./wsl.nix
    ./base-host.nix
  ];
}
