{
  pkgs,
  config,
  globals,
  lib,
  ...
}: let
  blesh-contrib = pkgs.callPackage ./pkgs {};
in {
  options.igloo.bash.blesh.enable =
    lib.mkEnableOption "Enable ble.sh with contrib extensions"
    // {
      default = true;
    };

  config = lib.mkIf config.igloo.bash.blesh.enable {
    home.packages = with pkgs.unstable;
      [
        blesh
      ]
      ++ [
        blesh-contrib
      ];

    # Override the basic blesh configuration from bash/config with full contrib setup
    home.file.".local/state/profile-sources/blesh.sh" = lib.mkForce {
      text = ''
        # ble.sh line editor configuration with contrib extensions
        if [ -n "''${PS1:-}" ] && [ -f "${pkgs.unstable.blesh}/share/blesh/ble.sh" ]; then
          # Set blesh-contrib path using the correct method
          if [[ -d "${blesh-contrib}/share/blesh-contrib" ]]; then
            BLE_CONTRIB_PATH="${blesh-contrib}/share/blesh-contrib:''${BLE_CONTRIB_PATH:-}"
          fi

          source ${pkgs.unstable.blesh}/share/blesh/ble.sh

          # Basic blesh options
          bleopt prompt_eol_mark=""

          # Share history across shells/panes in real time
          shopt -s histappend
          PROMPT_COMMAND='history -a; history -n; '"''${PROMPT_COMMAND:-}"

          # FZF integration - configure fzf base if needed
          _ble_contrib_fzf_base="${pkgs.fzf}/share/fzf"

          # FZF integrations
          ble-import -d integration/fzf-completion
          ble-import -d integration/fzf-key-bindings

          # Configure FZF git bindings
          _ble_contrib_fzf_git_config=key-binding:sabbrev:arpeggio
          ble-import -d integration/fzf-git

          # Load prompt modules immediately so sequences are available
          ble-import prompt-git

          # Configure prompts after modules are loaded
          bleopt prompt_rps1='\g{fg=69,italic}\q{contrib/git-info}'

          # Other integrations can be loaded asynchronously
          ble-import -d integration/nix-completion
          ble-import -d integration/zoxide

          # Color scheme - source directly, no dependencies
          if [[ -f "${blesh-contrib}/share/blesh-contrib/scheme/tokyonight.bash" ]]; then
            source "${blesh-contrib}/share/blesh-contrib/scheme/tokyonight.bash"
            ble/contrib/scheme:tokyonight/initialize 2>/dev/null || true
          fi

          # Additional useful configurations - use force flag for optional modules
        fi
      '';
    };
  };
}
