# System-wide packages and fonts configuration
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Essential tools
    wget
    just
    firefox
    foot
    helix
    # Display manager
    sddm-astronaut
  ];

  # System fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
    inter
    crimson-pro
  ];
}
