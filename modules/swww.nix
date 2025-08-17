# swww wallpaper daemon configuration
{
  lib,
  pkgs,
  globals,
  ...
}: let
  colors = import ../lib/themes globals;
in {
  # Include swww package in user environment
  home.packages = [pkgs.swww];

  # swww daemon service
  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww wallpaper daemon";
      After = ["graphical-session.target"];
      # Only start if WAYLAND_DISPLAY is set (i.e., Wayland session is running)
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.swww}-daemon";
      ExecStartPost = "${lib.getExe pkgs.swww} clear ${colors.ui.background.primary}";
      Restart = "on-failure";
      # Don't restart too quickly if Wayland isn't available
      RestartSec = "5s";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
