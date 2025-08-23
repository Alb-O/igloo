{
  pkgs,
  fonts,
  ...
}: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${fonts.mono.name}:size=${toString fonts.mono.size.large}, Symbols Nerd Font Mono";
        line-height = "20";
        term = "xterm-256color";
        dpi-aware = true;
        pad = "15x15";
        # Make new terminals spawn login shells so only ~/.profile is needed
        login-shell = "yes";
      };

      cursor = {
        style = "beam";
        blink = true;
        blink-rate = 250;
      };
    };
  };
}
