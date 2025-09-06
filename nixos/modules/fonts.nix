# System-wide font configuration and shared font defs injection
{ pkgs, lib, ... }:
let
  fonts = import ../../lib/fonts.nix { inherit pkgs; };
in
{
  # Make font defs available to all NixOS modules via specialArgs
  _module.args.fonts = fonts;

  # Install fonts system-wide so early-boot services (e.g., kmscon) can use them
  fonts.packages = fonts.packages;

  # Enable system fontconfig and defaults
  fonts.fontconfig = {
    enable = true;
    defaultFonts = fonts.defaultFonts;
  };
}

