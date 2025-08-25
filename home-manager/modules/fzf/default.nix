{
  pkgs,
  lib,
  globals,
  config,
  ...
}: let
  fzfOptions = [
    "--style=minimal"
    "--border=sharp"
    "--color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7"
    "--color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff"
    "--color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff"
    "--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"
    "--preview='file-preview {}'"
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
      FZF_DEFAULT_COMMAND = "rg --files";
      FZF_CTRL_T_COMMAND = "rg --files";
    };

    # Write fzf configuration to rc directory for easy sourcing
    home.file.".local/share/rc/fzf.sh".text = ''
      # FZF configuration
      if command -v fzf >/dev/null 2>&1; then
        export FZF_DEFAULT_OPTS="${lib.concatStringsSep " " fzfOptions}"
        export FZF_DEFAULT_COMMAND="rg --files"
        export FZF_CTRL_T_COMMAND="rg --files"
      fi
    '';
  };
}
