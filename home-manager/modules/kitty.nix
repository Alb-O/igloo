{ pkgs, ... }:
let
  colors = import ../../lib/themes;
  fonts = import ../../lib/fonts.nix pkgs;
in
{
  programs.kitty = {
    enable = true;
    font.name = fonts.mono.name;
    font.size = fonts.mono.size.normal;
    font.package = fonts.mono.package;
    settings = {
      # Basic appearance
      window_padding_width = 5;
      foreground = colors.ui.foreground.primary;
      background = colors.ui.background.primary;
      selection_foreground = colors.ui.foreground.inverse;
      selection_background = colors.ui.special.selection;

      cursor = colors.ui.foreground.primary;
      cursor_text_color = colors.ui.background.primary;
      url_color = colors.ui.interactive.primary;

      # Window and border styling
      active_border_color = colors.ui.border.focus;
      inactive_border_color = colors.ui.border.secondary;
      bell_border_color = colors.ui.interactive.accent;
      window_border_width = "1px";
      draw_minimal_borders = true;

      # OS Window titlebar colors
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";

      # Tab bar configuration
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{index}: {title[title.rfind('/')+1:]}";
      active_tab_foreground = colors.ui.background.primary;
      active_tab_background = colors.ui.interactive.primary;
      inactive_tab_foreground = colors.ui.foreground.secondary;
      inactive_tab_background = colors.ui.background.secondary;
      tab_bar_background = colors.ui.background.primary;

      # Layout and multiplexing settings
      enabled_layouts = "splits,stack,tall,grid";
      window_resize_step_cells = 2;
      window_resize_step_lines = 2;

      # Scrollback and history
      scrollback_lines = 10000;
      scrollback_pager_history_size = 2048;
      wheel_scroll_multiplier = "5.0";

      # Performance and behavior
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;

      # Copy/paste enhancements
      copy_on_select = false;
      strip_trailing_spaces = "smart";

      # Terminal feature support
      shell_integration = "enabled";
      allow_remote_control = "socket-only";

      # Marks for easy navigation
      mark1_foreground = colors.ui.background.primary;
      mark1_background = colors.ui.interactive.primary;
      mark2_foreground = colors.ui.background.primary;
      mark2_background = colors.ui.foreground.secondary;
      mark3_foreground = colors.ui.background.primary;
      mark3_background = colors.ui.interactive.secondary;

      # Terminal colors
      color0 = colors.terminal.black;
      color1 = colors.terminal.red;
      color2 = colors.terminal.green;
      color3 = colors.terminal.yellow;
      color4 = colors.terminal.blue;
      color5 = colors.terminal.magenta;
      color6 = colors.terminal.cyan;
      color7 = colors.terminal.white;
      color8 = colors.terminal.brightBlack;
      color9 = colors.terminal.brightRed;
      color10 = colors.terminal.brightGreen;
      color11 = colors.terminal.brightYellow;
      color12 = colors.terminal.brightBlue;
      color13 = colors.terminal.brightMagenta;
      color14 = colors.terminal.brightCyan;
      color15 = colors.terminal.brightWhite;
    };

    # Key bindings - Kitty defaults + custom additions
    keybindings = {
      # Layout management (replaces tmux prefix key workflow)
      "ctrl+shift+alt+l" = "next_layout";
      "ctrl+shift+alt+h" = "last_used_layout";

      # Window/pane creation (tmux-like splits)
      "f5" = "launch --location=hsplit --cwd=current";
      "f6" = "launch --location=vsplit --cwd=current";
      "f7" = "launch --location=split --cwd=current";

      # Window navigation (vim-like)
      "ctrl+h" = "neighboring_window left";
      "ctrl+j" = "neighboring_window down";
      "ctrl+k" = "neighboring_window up";
      "ctrl+l" = "neighboring_window right";

      # Window moving
      "ctrl+shift+h" = "move_window left";
      "ctrl+shift+j" = "move_window down";
      "ctrl+shift+k" = "move_window up";
      "ctrl+shift+l" = "move_window right";

      # Window resizing
      "alt+h" = "resize_window narrower 2";
      "alt+j" = "resize_window shorter 2";
      "alt+k" = "resize_window taller 2";
      "alt+l" = "resize_window wider 2";

      # Tab management (replaces tmux windows)
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";

      # Quick tab jumping
      "ctrl+1" = "goto_tab 1";
      "ctrl+2" = "goto_tab 2";
      "ctrl+3" = "goto_tab 3";
      "ctrl+4" = "goto_tab 4";
      "ctrl+5" = "goto_tab 5";
      "ctrl+6" = "goto_tab 6";
      "ctrl+7" = "goto_tab 7";
      "ctrl+8" = "goto_tab 8";
      "ctrl+9" = "goto_tab 9";

      # Window management
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+]" = "next_window";
      "ctrl+shift+[" = "previous_window";

      # Focus and zoom (like tmux zoom pane)
      "f9" = "goto_layout stack";
      "f10" = "last_used_layout";

      # Enhanced copy/paste
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+s" = "paste_from_selection";
      "ctrl+shift+o" = "pass_selection_to_program";

      # Scrollback navigation
      "ctrl+shift+alt+s" = "show_scrollback";
      "ctrl+shift+g" = "show_last_command_output";

      # Marks for quick navigation
      "f1" = "toggle_marker iregex 1 \\bERROR\\b";
      "f2" = "toggle_marker iregex 2 \\bWARN\\b";
      "f3" = "toggle_marker iregex 3 \\bINFO\\b";

      # Reload configuration
      "ctrl+shift+f5" = "load_config_file";
    };
  };
}
