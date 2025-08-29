# Global font configuration
{ pkgs, ... }: let
  fontDefs = rec {
    mono = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = {
        small = 11;
        normal = 13;
        large = 15;
      };
    };

    sansSerif = {
      name = "Fira Sans";
      package = pkgs.fira-sans;
      size = {
        small = 11;
        normal = 12;
        large = 14;
      };
    };

    serif = {
      name = "Crimson Pro";
      package = pkgs.crimson-pro;
      size = {
        small = 12;
        normal = 13;
        large = 15;
      };
    };

    # Font packages to install in user environment
    packages = with pkgs; [
      # Basic system fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji

      # Personal fonts
      nerd-fonts.jetbrains-mono
      inter
      crimson-pro

      # Sans serif fallback
      fira-sans
    ];

    # Fontconfig defaults and fallback configuration
    defaultFonts = {
      monospace = [
        mono.name
      ];
      sansSerif = [
        sansSerif.name
        "Inter"
      ];
      serif = [
        serif.name
      ];
      emoji = [
        "Noto Color Emoji"
      ];
    };
  };
in {
  # Export font definitions for use by other modules
  _module.args.fonts = fontDefs;

  # Install font packages in user environment
  home.packages = fontDefs.packages;

  # Enable fontconfig for user
  fonts.fontconfig.enable = true;

  # Configure font defaults and fallback
  fonts.fontconfig.defaultFonts = fontDefs.defaultFonts;
}
