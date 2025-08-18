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
    isort # Import sorter

    # Linters
    pylint # Python linter
    mypy # Static type checker

    # Development tools
    python3Packages.pytest # Testing framework
    python3Packages.ipython # Enhanced Python shell
    poetry # Dependency management
  ];
}
