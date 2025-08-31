{pkgs, ...}: {
  # Python development environment
  home.packages = with pkgs; [
    # Python runtime and package manager
    python3
    uv # Fast Python package installer and resolver

    # LSP servers
    pyright # Microsoft's Python LSP

    # Formatters
    black # Code formatter
  ];
}
