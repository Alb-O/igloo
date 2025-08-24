# Desktop environment and display manager configuration
{pkgs, ...}: {
  # Enable Niri window manager
  programs.niri.enable = true;

  # Display manager configuration
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Required for GNOME portal GSettings access
  programs.dconf.enable = true;

  # udev packages for desktop integration
  services.udev.packages = with pkgs; [gnome-settings-daemon];

  # Environment variables for desktop
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
