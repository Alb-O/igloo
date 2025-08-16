# Theme system with semantic color management
let
  # Available themes
  themes = {
    helix = import ./helix.nix;
    catppuccin = import ./catppuccin.nix;
    vscode = import ./vscode.nix;
  };

  # Active theme selection
  bootstrap = import ../bootstrap.nix;
  activeTheme = bootstrap.env.THEME or "vscode";

  # Get the active theme and generate semantic colors
  currentTheme = themes.${activeTheme};

  # Semantic color mappings
  getSemanticColors = theme: {
    ui = {
      background = {
        primary = theme.palette.neutral."500";
        secondary = theme.palette.neutral."400";
        tertiary = theme.palette.neutral."300";
      };

      foreground = {
        primary = theme.palette.neutral."50";
        secondary = theme.palette.neutral."100";
        tertiary = theme.palette.neutral."200";
        inverse = theme.palette.neutral."500";
      };

      interactive = {
        primary = theme.palette.primary;
        secondary = theme.palette.secondary;
        accent = theme.palette.accent;
        muted = theme.palette.muted;
      };

      border = {
        primary = theme.palette.neutral."300";
        secondary = theme.palette.neutral."400";
        focus = theme.palette.primary;
        active = theme.palette.accent;
      };

      status = {
        success = theme.palette.success;
        warning = theme.palette.warning;
        error = theme.palette.error;
        info = theme.palette.info;
      };

      special = {
        selection = theme.palette.primary;
        hover = theme.palette.neutral."300";
        pressed = theme.palette.neutral."400";
        highlight = theme.palette.highlight;
      };
    };

    terminal = {
      black = theme.palette.neutral."500";
      red = theme.palette.error;
      green = theme.palette.success;
      yellow = theme.palette.warning;
      blue = theme.palette.secondary;
      magenta = theme.palette.primary;
      cyan = theme.palette.muted;
      white = theme.palette.neutral."200";

      brightBlack = theme.palette.neutral."300";
      brightRed = theme.palette.error;
      brightGreen = theme.palette.success;
      brightYellow = theme.palette.highlight;
      brightBlue = theme.palette.secondary;
      brightMagenta = theme.palette.primary;
      brightCyan = theme.palette.muted;
      brightWhite = theme.palette.neutral."50";
    };
  };

  # Generate colors for current theme
  colors = getSemanticColors currentTheme;
in
  # Export colors directly
  colors
  // {
    # Theme metadata
    theme = {
      name = currentTheme.name;
      id = activeTheme;
    };

    # Raw palette access
    palette = currentTheme.palette;

    # Utils
    utils = {
      availableThemes = builtins.attrNames themes;
      hasTheme = themeName: builtins.hasAttr themeName themes;
      getThemeColors = themeName:
        if builtins.hasAttr themeName themes
        then getSemanticColors themes.${themeName}
        else throw "Theme '${themeName}' not found";
    };
  }
