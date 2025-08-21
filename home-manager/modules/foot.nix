{
  pkgs,
  globals,
  ...
}: let
  colors = import ../lib/themes globals;
  fonts = import ../lib/fonts.nix pkgs;

  # Helper function to strip # prefix from hex colors for foot
  stripHash = color: builtins.substring 1 6 color;
in {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${fonts.mono.name}:size=${toString fonts.mono.size.large}";
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

      colors = {
        background = stripHash colors.ui.background.primary;
        foreground = stripHash colors.ui.foreground.primary;

        regular0 = stripHash colors.terminal.black;
        regular1 = stripHash colors.terminal.red;
        regular2 = stripHash colors.terminal.green;
        regular3 = stripHash colors.terminal.yellow;
        regular4 = stripHash colors.terminal.blue;
        regular5 = stripHash colors.terminal.magenta;
        regular6 = stripHash colors.terminal.cyan;
        regular7 = stripHash colors.terminal.white;

        bright0 = stripHash colors.terminal.brightBlack;
        bright1 = stripHash colors.terminal.brightRed;
        bright2 = stripHash colors.terminal.brightGreen;
        bright3 = stripHash colors.terminal.brightYellow;
        bright4 = stripHash colors.terminal.brightBlue;
        bright5 = stripHash colors.terminal.brightMagenta;
        bright6 = stripHash colors.terminal.brightCyan;
        bright7 = stripHash colors.terminal.brightWhite;

        selection-foreground = stripHash colors.ui.foreground.inverse;
        selection-background = stripHash colors.ui.special.selection;
      };
    };
  };
}
