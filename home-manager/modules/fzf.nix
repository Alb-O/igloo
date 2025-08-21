{
  pkgs,
  lib,
  globals,
  config,
  ...
}: let
  colors = import ../lib/themes/default.nix globals;
  
  fzfOptions = [
    "--height=85%"
    "--layout=reverse"
    "--border=rounded"
    "--color=bg+:${colors.ui.background.primary}"
    "--color=bg:${colors.ui.background.primary}"
    "--color=spinner:${colors.ui.foreground.secondary}"
    "--color=hl:${colors.ui.status.error}"
    "--color=fg:${colors.ui.foreground.primary}"
    "--color=header:${colors.ui.status.error}"
    "--color=info:${colors.ui.interactive.primary}"
    "--color=pointer:${colors.ui.foreground.secondary}"
    "--color=marker:${colors.ui.interactive.secondary}"
    "--color=fg+:${colors.ui.foreground.primary}"
    "--color=prompt:${colors.ui.interactive.primary}"
    "--color=hl+:${colors.ui.status.error}"
    "--color=selected-bg:${colors.ui.special.hover}"
    "--color=border:${colors.ui.border.primary}"
    "--color=label:${colors.ui.foreground.primary}"
  ];
in {
  options.igloo.fzf.enable = lib.mkEnableOption "Enable themed fzf with sane defaults" // {default = true;};

  config = lib.mkIf config.igloo.fzf.enable {
    # Install fzf package
    home.packages = [pkgs.fzf];
    
    # Set FZF_DEFAULT_OPTS environment variable for shell integration
    home.sessionVariables = {
      FZF_DEFAULT_OPTS = lib.concatStringsSep " " fzfOptions;
    };
  };
}
