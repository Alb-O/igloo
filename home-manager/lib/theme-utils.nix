pkgs: globals: {
  colors = import ./themes globals;
  fonts = import ./fonts.nix pkgs;
  
  # Helper function to strip # prefix from hex colors (commonly used in terminals)
  stripHash = color: builtins.substring 1 6 color;
}