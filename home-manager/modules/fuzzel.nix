{pkgs, globals, ...}: let
  colors = import ../lib/themes globals;
  fonts = import ../lib/fonts.nix pkgs;
  # Helper to add alpha to hex color (e.g. "#3b224c" + "dd" -> "3b224cdd")
  hexNoHash = hex: builtins.replaceStrings ["#"] [""] hex;
  withAlpha = hex: alpha: hexNoHash hex + alpha;
in {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = fonts.mono.name;
        exit-on-keyboard-focus-loss = "no";
        prompt = "> ";
        line-height = 32;
        inner-pad = 24;
        width = 100;
        lines = 10;
        horizontal-pad = 40;
        vertical-pad = 40;
        match-counter = "yes";
        icon-theme = "Adwaita";
      };
      colors = {
        background = withAlpha colors.ui.background.primary "dd";
        input = withAlpha colors.ui.foreground.primary "ff";
        counter = withAlpha colors.ui.foreground.primary "ff";
        text = withAlpha colors.ui.interactive.primary "ee";
        placeholder = withAlpha colors.ui.background.primary "ff";
        selection = withAlpha colors.ui.special.selection "ee";
        selection-text = withAlpha colors.ui.foreground.inverse "ff";
        match = withAlpha colors.ui.status.error "ff";
      };
      border = {
        width = 0;
        radius = 0;
      };
    };
  };
}
