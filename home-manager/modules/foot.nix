{
  pkgs,
  fonts,
  ...
}: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${fonts.mono.name}:size=${toString fonts.mono.size.large}";
        line-height = "24";
        term = "xterm-256color";
        dpi-aware = true;
        pad = "25x20";
        # Make new terminals spawn login shells so only ~/.profile is needed
        login-shell = "yes";
      };

      cursor = {
        style = "beam";
        blink = true;
        blink-rate = 250;
      };

      colors = {
        foreground = "c0caf5";
        background = "1a1b26";
        selection-foreground = "c0caf5";
        selection-background = "2e3c64";
        urls = "73daca";
        regular0 = "f7768e";
        regular2 = "9ece6a";
        regular3 = "e0af68";
        regular4 = "7aa2f7";
        regular5 = "bb9af7";
        regular6 = "7dcfff";
        regular7 = "a9b1d6";
        bright1 = "f7768e";
        bright2 = "9ece6a";
        bright3 = "e0af68";
        bright4 = "7aa2f7";
        bright5 = "bb9af7";
        bright6 = "7dcfff";
      };
    };
  };
}
