{
  pkgs,
  fonts,
  ...
}: {
  programs.kitty = {
    enable = true;

    font = {
      name = fonts.mono.name;
      size = fonts.mono.size.large;
    };

    settings = {
      # Terminal behavior
      shell_integration = "enabled";
      term = "xterm-256color";
      shell = "bash -l";

      # Appearance
      background_opacity = "1.0";
      window_padding_width = "25 20";
      cursor_shape = "beam";
      cursor_blink_interval = "0.25";

      # Tokyo Night color scheme
      foreground = "#c0caf5";
      background = "#1a1b26";
      selection_foreground = "#c0caf5";
      selection_background = "#2e3c64";
      url_color = "#73daca";

      # Normal colors
      color0 = "#15161e";
      color1 = "#f7768e";
      color2 = "#9ece6a";
      color3 = "#e0af68";
      color4 = "#7aa2f7";
      color5 = "#bb9af7";
      color6 = "#7dcfff";
      color7 = "#a9b1d6";

      # Bright colors
      color8 = "#414868";
      color9 = "#f7768e";
      color10 = "#9ece6a";
      color11 = "#e0af68";
      color12 = "#7aa2f7";
      color13 = "#bb9af7";
      color14 = "#7dcfff";
      color15 = "#c0caf5";

      # Window layout
      remember_window_size = "no";
      initial_window_width = "640";
      initial_window_height = "400";

      # Performance
      repaint_delay = "10";
      input_delay = "3";
      sync_to_monitor = "yes";
    };
  };
}
