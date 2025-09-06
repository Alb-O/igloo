# NixOS modules aggregation
{ host, ... }:
{
  imports = [
    ./xdg.nix
    ./keyring.nix
    ./packages.nix
    ./keyboard.nix
    ./ssh.nix
    ./flake-configuration.nix
    ./wsl.nix
  ];
}
