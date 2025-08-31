{...}: {
  # Import all language-specific configurations
  imports = [
    ./rust.nix
    ./nix.nix
    ./markdown.nix
    ./python.nix
    # ./javascript.nix
    # ./go.nix
    # ./c.nix
  ];
}
