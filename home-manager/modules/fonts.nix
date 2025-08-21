{pkgs, globals, ...}: let
  fonts = import ../lib/fonts.nix pkgs;
in {
  # Install font packages in user environment
  home.packages = with pkgs; [
    # Basic system fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    
    # Personal fonts with nerd symbol support via fallback
    nerd-fonts.symbols-only
    jetbrains-mono
    inter
    crimson-pro
    
    # Sans serif fallback
    fira-sans
  ];

  # Enable fontconfig for user
  fonts.fontconfig.enable = true;
  
  # Configure font defaults and fallback
  fonts.fontconfig.defaultFonts = {
    monospace = [
      fonts.mono.name
      "Symbols Nerd Font Mono"
    ];
    sansSerif = [
      fonts.sansSerif.name
      "Inter"
    ];
    serif = [
      fonts.serif.name
    ];
    emoji = [
      "Noto Color Emoji"
    ];
  };
}