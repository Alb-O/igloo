{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "dark_plus_transparent";
      editor = {
        true-color = true;
        line-number = "relative";
        scrolloff = 5;
        soft-wrap = {
          enable = true;
          max-wrap = 25;
        };
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }
    ];
    themes = {
      dark_plus_transparent = {
        "inherits" = "dark_plus";
        "ui.background" = { };
      };
    };
  };
}
