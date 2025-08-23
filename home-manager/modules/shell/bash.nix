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

  # Disable HM-managed Bash init files; we'll handle everything via ~/.profile
  programs.bash.enable = lib.mkForce false;

  home.packages = with pkgs.unstable; [
    blesh
  ];

  # Write ble.sh configuration to profile sources directory for easy sourcing
  home.file.".local/state/profile-sources/blesh.sh".text = ''
    # ble.sh line editor configuration
    if [ -n "''${PS1:-}" ] && [ -f "${pkgs.unstable.blesh}/share/blesh/ble.sh" ]; then
      source ${pkgs.unstable.blesh}/share/blesh/ble.sh
      bleopt prompt_eol_mark=""

      # Share history across shells/panes in real time
      shopt -s histappend
      PROMPT_COMMAND='history -a; history -n; '"''${PROMPT_COMMAND:-}"
    fi
  '';
}
