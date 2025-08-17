{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "dark_plus";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
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
      #dark_plus_custom = {
      #  "inherits" = "dark_plus";
      #  "ui.background" = { };
      #};
    };
  };
}
