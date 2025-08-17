{pkgs, ...}: let
  colors = import ../../lib/themes;
  fonts = import ../../lib/fonts.nix pkgs;
in {
  programs.alacritty = {
    enable = true;
    settings = {
      window.padding = { x = 10; y = 10; };

      font = {
        normal.family = fonts.mono.name;
        size = fonts.mono.size.normal;
      };

      cursor.style.blinking = "Always";

      colors = {
        primary = {
          background = colors.ui.background.primary;
          foreground = colors.ui.foreground.primary;
        };
        cursor = {
          text = colors.ui.background.primary;
          cursor = colors.ui.foreground.primary;
        };
        selection = {
          text = colors.ui.foreground.inverse;
          background = colors.ui.special.selection;
        };
        normal = {
          black = colors.terminal.black;
          red = colors.terminal.red;
          green = colors.terminal.green;
          yellow = colors.terminal.yellow;
          blue = colors.terminal.blue;
          magenta = colors.terminal.magenta;
          cyan = colors.terminal.cyan;
          white = colors.terminal.white;
        };
        bright = {
          black = colors.terminal.brightBlack;
          red = colors.terminal.brightRed;
          green = colors.terminal.brightGreen;
          yellow = colors.terminal.brightYellow;
          blue = colors.terminal.brightBlue;
          magenta = colors.terminal.brightMagenta;
          cyan = colors.terminal.brightCyan;
          white = colors.terminal.brightWhite;
        };
      };
    };
  };
}