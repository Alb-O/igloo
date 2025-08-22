{pkgs, ...}: {
  programs.bat = {
    enable = true;
    config = {
      # Use custom Helix-inspired theme
      theme = "helix-dark-plus";
      # Show line numbers
      style = "numbers,changes,header";
      # Wrap long lines
      wrap = "auto";
      # Color output even when piped
      color = "always";
    };
    # Install custom theme
    themes = {
      helix-dark-plus = {
        src = ./themes/helix-dark-plus.tmTheme;
      };
    };
  };
}
