{
  name = "VS Code Dark+";
  palette = {
    # Neutral scale based on VS Code Dark+ theme
    neutral = {
      "50" = "#DCDCDC"; # foreground - main text color
      "100" = "#C6C6C6"; # light_gray2 - slightly dimmed text
      "200" = "#858585"; # dark_gray - line numbers, muted text
      "300" = "#404040"; # dark_gray4 - indent guides, borders
      "400" = "#282828"; # dark_gray3 - current line bg
      "500" = "#1E1E1E"; # dark_gray2 - main background
    };

    # VS Code Dark+ semantic colors (exact matches from tmTheme/toml)
    primary = "#569CD6"; # blue2 - keywords, types
    secondary = "#C586C0"; # special - keywords, operators
    accent = "#DCDCAA"; # fn_declaration - function names
    success = "#6A9955"; # dark_green - comments
    warning = "#D7BA7D"; # gold - CSS selectors, escapes
    error = "#F14C4C"; # orange_red - errors
    info = "#75BEFF"; # light_blue - info messages
    highlight = "#264F78"; # dark_blue - selection background
    muted = "#608B4E"; # comment color

    # Code syntax colors (exact from theme files)
    variable = "#9CDCFE"; # variables, CSS properties
    string = "#CE9178"; # orange - strings
    number = "#B5CEA8"; # pale_green - numbers, constants
    type = "#4EC9B0"; # type names, class names
    function = "#DCDCAA"; # function declarations
    keyword = "#569CD6"; # keywords, built-ins
    operator = "#C586C0"; # operators
    comment = "#6A9955"; # comments

    # Background and UI colors
    background = "#1E1E1E";
    foreground = "#DCDCDC";
    cursor = "#DCDCDC";
    selection = "#264F78";
    line_highlight = "#282828";

    # Widget and border colors
    widget = "#252526";
    border = "#404040";
  };
}
