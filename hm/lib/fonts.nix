# Global font configuration (Home Manager wrapper around shared lib)
{ pkgs, ... }:
let
  fonts = import ../../lib/fonts.nix { inherit pkgs; };
in
{
  # Export font definitions for use by other modules
  _module.args.fonts = fonts;

  # Install font packages in user environment
  home.packages = fonts.packages;

  # Enable fontconfig for user
  fonts.fontconfig.enable = true;

  # Configure font defaults and fallback
  fonts.fontconfig.defaultFonts = fonts.defaultFonts;
}
