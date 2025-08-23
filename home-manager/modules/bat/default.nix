{pkgs, ...}: {
  programs.bat = {
    enable = true;
    config = {
      # Show line numbers
      style = "numbers,changes,header";
      # Wrap long lines
      wrap = "auto";
      # Color output even when piped
      color = "always";
    };
  };
}
