{
  pkgs,
  lib,
  globals,
  config,
  ...
}: let
  fzfOptions = [
    "--style=minimal"
    "--border=none"
    "--preview='sh ${./scripts/fzf-preview.sh} {}'"
    "--tmux 90%,100%"
  ];
in {
  options.igloo.fzf.enable =
    lib.mkEnableOption "Enable fzf with sane defaults"
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
