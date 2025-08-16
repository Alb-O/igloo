# Home Manager configuration
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  globals,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "nixbackup";
    sharedModules = [
      inputs.niri-flake.homeModules.config
    ];
    users.${globals.user.username} = import ../../home-manager/home.nix {
      inherit
        inputs
        outputs
        lib
        config
        pkgs
        globals
        ;
    };
  };
}
