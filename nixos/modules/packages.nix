# System-wide packages configuration
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Essential tools
    wget
    just # Task runner for development workflows

    # Emergency root access tools
    firefox # Web browser for root emergency access
    alacritty # Terminal emulator for root emergency access
    kitty # Alternative terminal emulator
    helix # Text editor for emergency configuration editing

    # Desktop and GTK support
    nautilus # Required for GTK4 file pickers via xdg-desktop-portal-gnome delegation
    tinysparql # Tracker3 file indexing service (renamed from tracker)
    localsearch # File content miners for Tracker3 (renamed from tracker-miners)
    adwaita-icon-theme # Complete Adwaita theme with GTK4 support
    libadwaita # GTK4 Adwaita library and themes
    gtk4 # GTK4 runtime with proper theme support

    # Display manager
    sddm-astronaut
  ];
}
