{
  pkgs,
  lib,
  globals,
  config,
  ...
}: let
  colors = import ../../lib/themes globals;

  fzfOptions = [
    "--style=minimal"
    "--border=none"
    "--preview='sh ${./scripts/fzf-preview.sh} {}'"
    "--color=bg+:-1"
    "--color=bg:-1"
    "--color=gutter:-1"
    "--color=spinner:${colors.ui.foreground.secondary}"
    "--color=hl:${colors.ui.status.error}"
    "--color=fg:${colors.ui.foreground.primary}"
    "--color=header:${colors.ui.status.error}"
    "--color=info:${colors.ui.interactive.primary}"
    "--color=pointer:${colors.ui.foreground.secondary}"
    "--color=marker:${colors.ui.interactive.secondary}"
    "--color=fg+:${colors.ui.foreground.primary}:underline"
    "--color=prompt:${colors.ui.interactive.primary}"
    "--color=hl+:${colors.ui.status.error}"
    "--color=border:${colors.ui.border.primary}"
    "--color=label:${colors.ui.foreground.primary}"
    "--tmux 90%,100%,border-native"
  ];
in {
  options.igloo.fzf.enable =
    lib.mkEnableOption "Enable themed fzf with sane defaults"
    // {
      default = true;
    };

  config = lib.mkIf config.igloo.fzf.enable {
    # Install fzf package
    home.packages = [pkgs.fzf];

    # Set FZF_DEFAULT_OPTS environment variable for shell integration
    home.sessionVariables = {
      FZF_DEFAULT_OPTS = lib.concatStringsSep " " fzfOptions;
    };

    # Write fzf configuration to profile sources directory for easy sourcing
    home.file.".local/state/profile-sources/fzf.sh".text = ''
      # FZF configuration
      if command -v fzf >/dev/null 2>&1; then
        export FZF_DEFAULT_OPTS="${lib.concatStringsSep " " fzfOptions}"
      fi
    '';
  };
}
