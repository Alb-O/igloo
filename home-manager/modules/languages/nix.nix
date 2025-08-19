{pkgs, ...}: {
  # Nix language support
  home.packages = with pkgs; [
    # Nix LSP servers
    nil
    nixd

    # Nix formatting
    nixfmt-rfc-style
    alejandra
  ];
}
