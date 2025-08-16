# Firefox colorscheme integration
# Converts our colorscheme to nix-colors format and generates userstyles
{
  inputs,
  pkgs,
  ...
}: let
  colors = import ../../../lib/themes;

  # Convert our colorscheme to nix-colors format (remove # from hex colors)
  nixColorsCompatiblePalette = {
    base00 = builtins.substring 1 6 colors.palette.neutral."500"; # Default Background
    base01 = builtins.substring 1 6 colors.palette.neutral."400"; # Lighter Background
    base02 = builtins.substring 1 6 colors.palette.neutral."300"; # Selection Background
    base03 = builtins.substring 1 6 colors.palette.neutral."200"; # Comments, Invisibles
    base04 = builtins.substring 1 6 colors.palette.primary; # Dark Foreground
    base05 = builtins.substring 1 6 colors.palette.neutral."50"; # Default Foreground
    base06 = builtins.substring 1 6 colors.palette.neutral."100"; # Light Foreground
    base07 = builtins.substring 1 6 colors.palette.neutral."50"; # Light Background
    base08 = builtins.substring 1 6 colors.palette.error; # Variables, Tags
    base09 = builtins.substring 1 6 colors.palette.warning; # Integers, Constants
    base0A = builtins.substring 1 6 colors.palette.highlight; # Classes, Bold
    base0B = builtins.substring 1 6 colors.palette.success; # Strings, Code
    base0C = builtins.substring 1 6 colors.palette.muted; # Support, RegExp
    base0D = builtins.substring 1 6 colors.palette.secondary; # Functions, Methods
    base0E = builtins.substring 1 6 colors.palette.primary; # Keywords, Storage
    base0F = builtins.substring 1 6 colors.palette.error; # Deprecated
  };

  # Popular websites to style
  supportedSites = [
    "github"
    "google"
    "youtube"
    "reddit"
    "stackoverflow"
    "duckduckgo"
    "wikipedia"
    "twitter"
    "chatgpt"
    "whatsapp-web"
    "spotify"
  ];

  # Generate userstyles using nix-userstyles (only if available)
  userStyles =
    if inputs ? nix-userstyles && inputs.nix-userstyles ? packages.${pkgs.system}.mkUserStyles
    then inputs.nix-userstyles.packages.${pkgs.system}.mkUserStyles nixColorsCompatiblePalette supportedSites
    else "";
in {
  inherit nixColorsCompatiblePalette supportedSites userStyles;
}
