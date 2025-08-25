# Foot terminal server using socket activation
# Uses the systemd units provided by the foot package
{pkgs, ...}: {
  # Enable foot server socket (this will auto-start the service when needed)
  systemd.user.sockets.foot-server = {
    Unit = {
      Description = "Foot terminal server socket";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Socket = {
      ListenStream = "%t/foot.sock";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # The service will be auto-started when the socket is accessed
  systemd.user.services.foot-server = {
    Unit = {
      Description = "Foot terminal server mode";
      Documentation = "man:foot(1)";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
      ConditionEnvironment = "WAYLAND_DISPLAY";
      Requires = ["foot-server.socket"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.foot}/bin/foot --server=3";
      UnsetEnvironment = "LISTEN_PID LISTEN_FDS LISTEN_FDNAMES";
      NonBlocking = true;
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
