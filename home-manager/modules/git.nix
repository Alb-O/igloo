{
  pkgs,
  lib,
  globals,
  inputs,
  ...
}: {
  programs.git = {
    enable = true;
    userName = globals.user.name;
    userEmail = globals.user.email;

    aliases = {
      # Compound commands
      undo = "reset --soft HEAD~1";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";
      branches = "branch -a";
      remotes = "remote -v";
    };

    extraConfig =
      {
        # Core settings
        init.defaultBranch = "main";
        core = {
          editor = globals.editor;
          autocrlf = false;
          safecrlf = true;
          filemode = true;
        };

        # Pull/push behavior
        pull = {
          rebase = false;
          ff = "only";
        };
        push = {
          default = "simple";
          autoSetupRemote = true;
        };

        # Merge and rebase settings
        merge = {
          ff = false;
          conflictstyle = "diff3";
        };
        rebase = {
          autostash = true;
          autosquash = true;
        };

        # Diff and status improvements
        diff = {
          algorithm = "patience";
          renames = "copies";
          mnemonicPrefix = true;
        };
        status = {
          showUntrackedFiles = "all";
          submoduleSummary = true;
        };

        # Color output
        color = {
          ui = "auto";
          branch = "auto";
          diff = "auto";
          status = "auto";
        };

        # Helpful settings
        help.autocorrect = 1;
        rerere.enabled = true;
        log.date = "relative";

        # Note: AI context is added via prepare-commit-msg hook below

        # GitHub CLI credential helpers
        credential."https://github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
        credential."https://gist.github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
      }
      # Git signing configuration (if signing key is available in environment)
      // (
        let
          signingKey = builtins.getEnv "SIGNING_KEY";
        in
          if signingKey != ""
          then {
            gpg = {
              format = "ssh";
            };
            commit = {
              gpgsign = true;
            };
            user = {
              signingKey = signingKey;
            };
          }
          else {}
      );

    ignores = [
      # OS files
      ".DS_Store"
      "Thumbs.db"

      # Temporary files
      "*~"
      "*.swp"
      "*.tmp"

      # Build artifacts
      "node_modules/"
      "dist/"
      "build/"
      "target/"

      # Nix
      "result"
      "result-*"
    ];
  };

  # lazygit
  programs.lazygit = {
    enable = true;
  };
}
