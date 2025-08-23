{
  pkgs,
  fonts,
  ...
}: {
  services.mako = {
    enable = true;

    settings = {
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
  };
}
