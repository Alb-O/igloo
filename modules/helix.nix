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
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        }
        {
          name = "rust";
          roots = [
            "Cargo.toml"
            "Cargo.lock"
          ];
          auto-format = true;
          formatter.command = "${pkgs.rustfmt}/bin/rustfmt";
        }
      ];
      language-server = {
        rust-analyzer = {
          config = {
            # check = {
            #   command = "clippy";
            # };
            diagnostics = {
              styleLints.enable = true;
            };
          };
        };
      };
    };
    themes = {
      dark_plus_transparent = {
        "inherits" = "dark_plus";
        "ui.background" = { };
      };
    };
  };
}
