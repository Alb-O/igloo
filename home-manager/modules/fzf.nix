{ pkgs, lib, globals, config, ... }:
let
  theme = import ../lib/themes/default.nix globals;
in
{
  options.igloo.fzf.enable = lib.mkEnableOption "Enable themed fzf with sane defaults" // { default = true; };
  options.igloo.fzf.style = lib.mkOption {
    type = lib.types.attrs;
    default = {
      height = "85%";
      layout = "reverse";
      border = "rounded";
      colors = {
        bg = theme.ui.background.primary;
        fg = theme.ui.foreground.primary;
        hl = theme.ui.interactive.primary;
      };
    };
    description = "FZF layout and color styling.";
  };

  config = lib.mkIf config.igloo.fzf.enable {
    programs.fzf = {
      enable = true;
      defaultOptions = [
        "--height=${config.igloo.fzf.style.height}"
        "--layout=${config.igloo.fzf.style.layout}"
        "--border=${config.igloo.fzf.style.border}"
        "--color=bg:${config.igloo.fzf.style.colors.bg},fg:${config.igloo.fzf.style.colors.fg},hl:${config.igloo.fzf.style.colors.hl}"
      ];
    };
  };
}
