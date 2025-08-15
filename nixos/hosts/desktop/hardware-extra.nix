# Extra hardware-specific configuration
{ lib, ... }:
{
  # Hardware fan control (no config here)
  hardware.fancontrol = {
    enable = true;
    config = ""; # Set to empty string to satisfy type requirement
  };

  # Systemd oneshot service to generate /run/fancontrol.conf at boot
  systemd.services.fancontrol-generate-config = {
    description = "Generate fancontrol config with correct hwmon indices";
    wantedBy = [ "multi-user.target" ];
    before = [ "fancontrol.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
            set -e
            # Find the hwmon index for nct6779
            for d in /sys/class/hwmon/hwmon*/name; do
              if grep -q nct6779 "$d"; then
                idx=$(basename $(dirname "$d"))
                break
              fi
            done
            if [ -z "$idx" ]; then
              echo "nct6779 hwmon device not found!" >&2
              exit 1
            fi
            cat > /run/fancontrol.conf <<EOF
      # Generated at boot
      INTERVAL=10
      DEVPATH=hwmon1=devices/pci0000:00/0000:00:18.3 $idx=devices/platform/nct6775.656
      DEVNAME=hwmon1=k10temp $idx=nct6779
      FCTEMPS=$idx/pwm2=hwmon1/temp1_input $idx/pwm3=hwmon1/temp1_input
      FCFANS=$idx/pwm2=$idx/fan2_input
      MINTEMP=$idx/pwm2=65 $idx/pwm3=65
      MAXTEMP=$idx/pwm2=90 $idx/pwm3=90
      MINSTART=$idx/pwm2=30 $idx/pwm3=30
      MINSTOP=$idx/pwm2=20 $idx/pwm3=20
      EOF
    '';
  };

  # Override fancontrol service to use /run/fancontrol.conf and depend on generator
  systemd.services.fancontrol = {
    after = [ "fancontrol-generate-config.service" ];
    requires = [ "fancontrol-generate-config.service" ];
    serviceConfig.ExecStart = lib.mkForce "/run/current-system/sw/bin/fancontrol /run/fancontrol.conf";
    unitConfig.X-StopOnReconfiguration = false;
  };

  # Load sensor modules for fancontrol
  boot.kernelModules = [
    "k10temp"
    "nct6775"
  ];
}
