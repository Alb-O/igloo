{
  pkgs,
  config,
  globals,
  lib,
  ...
}: {
  imports = [
    ./starship.nix
  ];

  options.igloo.bash.enable = 
    lib.mkEnableOption "Enable Bash configuration"
    // {
      default = true;
    };

  config = lib.mkIf config.igloo.bash.enable {
    # Disable HM-managed Bash init files; we'll handle everything via ~/.profile
    programs.bash.enable = lib.mkForce false;

    # Basic blesh configuration (only if blesh contrib module is disabled)
    home.file.".local/state/profile-sources/blesh.sh" = lib.mkIf (!config.igloo.bash.blesh.enable) {
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