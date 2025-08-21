{
  pkgs,
  globals,
  fonts,
  ...
}: let
  colors = import ../lib/themes globals;
in {
  services.mako = {
    enable = true;

    settings = {
      # Basic appearance
      background-color = colors.ui.background.primary;
      text-color = colors.ui.foreground.primary;
      border-color = colors.ui.border.primary;
      progress-color = colors.ui.interactive.primary;

      # Font configuration
      font = "${fonts.mono.name} ${toString fonts.mono.size.normal}";

      # Layout and positioning
      width = 400;
      height = 150;
      margin = "10";
      padding = "15";
      border-size = 2;
      border-radius = 0;

      # Behavior
      default-timeout = 5000;
      ignore-timeout = true;
      layer = "overlay";
      anchor = "top-right";
    };

    # Categories with different colors
    extraConfig = ''
      [urgency=low]
      border-color=${colors.ui.status.info}

      [urgency=normal]
      border-color=${colors.ui.border.primary}

      [urgency=critical]
      border-color=${colors.ui.status.error}
      background-color=${colors.ui.status.error}
      text-color=${colors.ui.background.primary}

      [category=screenshot]
      border-color=${colors.ui.status.success}

      [app-name=volume]
      border-color=${colors.ui.interactive.accent}
    '';
  };
}
