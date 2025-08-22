{
  pkgs,
  config,
  globals,
  lib,
  ...
}: let
  colors = import ../../lib/themes globals;
in {
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

      # Theme-integrated ble.sh colors
      ble-face -s region                    fg=${colors.ui.foreground.primary}
      ble-face -s region_target             fg=${colors.ui.foreground.inverse}
      ble-face -s region_match              fg=${colors.ui.foreground.primary}
      ble-face -s region_insert             fg=${colors.ui.interactive.secondary}
      ble-face -s disabled                  fg=${colors.ui.foreground.tertiary}
      ble-face -s overwrite_mode            fg=${colors.ui.foreground.inverse},bg=${colors.ui.interactive.accent}
      ble-face -s vbell                     reverse
      ble-face -s vbell_erase               none
      ble-face -s vbell_flash               fg=${colors.ui.status.success},reverse
      ble-face -s prompt_status_line        fg=${colors.ui.foreground.primary}

      # syntax highlighting (backgrounds removed)
      ble-face -s syntax_default            none
      ble-face -s syntax_command            fg=${colors.terminal.yellow}
      ble-face -s syntax_quoted             fg=${colors.terminal.green}
      ble-face -s syntax_quotation          fg=${colors.terminal.green},bold
      ble-face -s syntax_escape             fg=${colors.terminal.magenta}
      ble-face -s syntax_expr               fg=${colors.terminal.blue}
      ble-face -s syntax_error              fg=${colors.ui.status.error}
      ble-face -s syntax_varname            fg=${colors.palette.highlight}
      ble-face -s syntax_delimiter          bold
      ble-face -s syntax_param_expansion    fg=${colors.terminal.magenta}
      ble-face -s syntax_history_expansion  fg=${colors.terminal.yellow}
      ble-face -s syntax_function_name      fg=${colors.ui.interactive.primary},bold
      ble-face -s syntax_comment            fg=${colors.ui.foreground.tertiary}
      ble-face -s syntax_glob               fg=${colors.ui.status.error},bold
      ble-face -s syntax_brace              fg=${colors.terminal.cyan},bold
      ble-face -s syntax_tilde              fg=${colors.ui.interactive.secondary},bold
      ble-face -s syntax_document           fg=${colors.terminal.green}
      ble-face -s syntax_document_begin     fg=${colors.terminal.green},bold
      # Avoid alarming colors for shell builtins like 'cd'
      ble-face -s command_builtin_dot       fg=${colors.terminal.blue},bold
      ble-face -s command_builtin           fg=${colors.terminal.blue}
      ble-face -s command_alias             fg=${colors.terminal.cyan}
      ble-face -s command_function          fg=${colors.ui.interactive.primary}
      ble-face -s command_file              fg=${colors.terminal.green}
      ble-face -s command_keyword           fg=${colors.terminal.blue}
      ble-face -s command_jobs              fg=${colors.terminal.red}
      ble-face -s command_directory         fg=${colors.terminal.blue},underline
      ble-face -s filename_directory        underline,fg=${colors.terminal.blue}
      ble-face -s filename_directory_sticky underline,fg=${colors.ui.foreground.primary}
      ble-face -s filename_link             underline,fg=${colors.terminal.cyan}
      ble-face -s filename_orphan           underline,fg=${colors.ui.status.warning}
      ble-face -s filename_executable       underline,fg=${colors.terminal.green}
      ble-face -s filename_setuid           underline,fg=${colors.ui.status.warning}
      ble-face -s filename_setgid           underline,fg=${colors.ui.status.warning}
      ble-face -s filename_other            underline
      ble-face -s filename_socket           underline,fg=${colors.terminal.cyan}
      ble-face -s filename_pipe             underline,fg=${colors.terminal.green}
      ble-face -s filename_character        underline,fg=${colors.ui.foreground.primary}
      ble-face -s filename_block            underline,fg=${colors.terminal.yellow}
      ble-face -s filename_warning          underline,fg=${colors.ui.status.error}
      ble-face -s filename_url              underline,fg=${colors.terminal.blue}
      ble-face -s filename_ls_colors        underline
      ble-face -s varname_array             fg=${colors.palette.highlight},bold
      ble-face -s varname_empty             fg=${colors.ui.foreground.tertiary}
      ble-face -s varname_export            fg=${colors.ui.interactive.primary},bold
      ble-face -s varname_expr              fg=${colors.ui.interactive.primary},bold
      ble-face -s varname_hash              fg=${colors.terminal.green},bold
      ble-face -s varname_number            fg=${colors.terminal.green}
      ble-face -s varname_readonly          fg=${colors.ui.interactive.primary}
      ble-face -s varname_transform         fg=${colors.terminal.green},bold
      ble-face -s varname_unset             fg=${colors.ui.foreground.tertiary}
      ble-face -s argument_option           fg=${colors.terminal.cyan}
      ble-face -s argument_error            fg=${colors.ui.status.error}

      # highlighting for completions (backgrounds removed except for selections)
      ble-face -s auto_complete             fg=${colors.ui.foreground.tertiary}

      # Share history across shells/panes in real time
      shopt -s histappend
      PROMPT_COMMAND='history -a; history -n; '"''${PROMPT_COMMAND:-}"
    fi
  '';
}
