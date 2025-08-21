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
          language-servers = [
            "nil"
            "helix-gpt"
          ];
        }
        {
          name = "rust";
          roots = [
            "Cargo.toml"
            "Cargo.lock"
          ];
          auto-format = true;
          formatter.command = "${pkgs.rustfmt}/bin/rustfmt";
          language-servers = [
            "rust-analyzer"
            "helix-gpt"
          ];
        }
        {
          name = "markdown";
          language-servers = [
            "markdown-oxide"
            "helix-gpt"
          ];
          auto-format = true;
          formatter.command = "${pkgs.prettier}/bin/prettier";
        }
        {
          name = "git-commit";
          language-servers = [
            "helix-gpt"
          ];
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
        helix-gpt = {
          command = "helix-gpt";
          environment = {
            COPILOT_API_KEY = builtins.getEnv "COPILOT_API_KEY";
            HANDLER = builtins.getEnv "HANDLER";
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
