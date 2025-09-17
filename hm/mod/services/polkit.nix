# Polkit GNOME authentication agent for user session
{pkgs, lib, host, ...}: 
lib.mkIf host.isGraphical {
  # Polkit authentication agent service
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = ["graphical-session.target"];
      WantedBy = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 1;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
