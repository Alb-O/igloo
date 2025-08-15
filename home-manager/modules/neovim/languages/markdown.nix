{ pkgs, ... }:
{
  # Markdown development environment
  home.packages = with pkgs; [
    # LSP and language servers
    marksman # Markdown LSP server
    markdown-oxide # PKM Markdown Language Server

    # Formatters and linters
    markdownlint-cli # Markdown linter
    pandoc # Document converter

    # Preview and utilities
    glow # Terminal markdown viewer
    mdcat # Markdown viewer with syntax highlighting

    # Spell checking
    hunspell
    hunspellDicts.en_US

    # Additional tools
    vale # Prose linter
    write-good # English prose linter
  ];
}
