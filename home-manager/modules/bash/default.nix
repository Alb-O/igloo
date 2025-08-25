{
  pkgs,
  config,
  globals,
  lib,
  ...
}: {
  imports = [
    ./blesh
  ];

  options.igloo.bash.enable =
    lib.mkEnableOption "Enable Bash configuration"
    // {
      default = true;
    };

  config = {
    # Enable the bash module with default settings
    igloo.bash = {
      enable = lib.mkDefault true;
      blesh.enable = lib.mkDefault true;
    };

    # Disable HM-managed Bash init files; we'll handle everything via ~/.profile
    programs.bash.enable = lib.mkIf config.igloo.bash.enable (lib.mkForce false);

    # Basic blesh configuration (only if blesh contrib module is disabled)
    home.file.".local/share/rc/blesh.sh" = lib.mkIf (config.igloo.bash.enable && !config.igloo.bash.blesh.enable) {
      text = ''
        # Basic ble.sh line editor configuration
        if [ -n "''${PS1:-}" ] && [ -f "${pkgs.unstable.blesh}/share/blesh/ble.sh" ]; then
          source ${pkgs.unstable.blesh}/share/blesh/ble.sh
          bleopt prompt_eol_mark=""

          # Share history across shells/panes in real time
          shopt -s histappend
          PROMPT_COMMAND='history -a; history -n; '"''${PROMPT_COMMAND:-}"
        fi
      '';
    };
  };
}
