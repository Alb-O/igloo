{
  pkgs,
  config,
  globals,
  lib,
  ...
}:
let
  colors = import ../../lib/themes globals;
in
{
  imports = [
    ./starship.nix
    ./direnv.nix
  ];

  # Disable HM-managed Bash init files; we’ll handle everything via ~/.profile
  programs.bash.enable = lib.mkForce false;

  home.packages = with pkgs.unstable; [
    blesh
  ];
}
