{
  pkgs,
  config,
  globals,
  lib,
  ...
}: {
  imports = [
    ./config
    ./blesh
  ];

  # Enable the bash module
  igloo.bash = {
    enable = lib.mkDefault true;
    blesh.enable = lib.mkDefault true;
  };
}