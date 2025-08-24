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
    home.packages = with pkgs.unstable; [
      blesh
    ] ++ [
      blesh-contrib
    ];

    # Write .blerc configuration file
    home.file.".blerc".text = ''
      # Set blesh-contrib path using the correct method
      if [[ -d "${blesh-contrib}/share/blesh-contrib" ]]; then
        BLE_CONTRIB_PATH="${blesh-contrib}/share/blesh-contrib:''${BLE_CONTRIB_PATH:-}"
      fi

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
      ble-import prompt-vim-mode  
      ble-import prompt-elapsed

      # Configure prompts after modules are loaded
      bleopt prompt_rps1='\g{fg=69,italic}\q{contrib/elapsed} \q{contrib/git-info}'
      bleopt keymap_vi_mode_show:=
      PS1='[\u@\h \W]\q{contrib/vim-mode}\$ '

      # Other integrations can be loaded asynchronously
      ble-import -d integration/nix-completion
      ble-import -d integration/zoxide

      # Color scheme
      ble-import -df scheme/catppuccin_mocha

      # Additional useful configurations - use force flag for optional modules
      ble-import -df config/execmark
      ble-import -df config/github481-elapsed-mark-without-command
      ble-import -df config/github483-elapsed-mark-on-error
    '';
  };
}