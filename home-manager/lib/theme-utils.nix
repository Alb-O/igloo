pkgs: globals: fonts: {
  colors = import ./themes globals;
  inherit fonts;
  
  # Helper function to strip # prefix from hex colors (commonly used in terminals)
  stripHash = color: builtins.substring 1 6 color;
}