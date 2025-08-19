{
  pkgs,
  lib,
  globals,
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

    extraConfig = {
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

      # GitHub CLI credential helpers
      credential."https://github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
      credential."https://gist.github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
    };

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

  # Fish shell aliases for git commands
  programs.fish.shellAliases = {
    # 2-letter commands
    gs = "git status";
    gb = "git branch";
    gc = "git checkout";
    gd = "git diff";
    gl = "git log --oneline --graph --decorate";
    ga = "git add";
    gm = "git commit -m";
    gp = "git push";
    gu = "git pull";
    gf = "git fetch";

    # 3-letter commands
    gcb = "git checkout -b";
    gam = "git commit -am";
    gmn = "git commit --amend --no-edit";
    grs = "git reset";
    grb = "git rebase";

    # Compound commands
    gundo = "git undo";
    glast = "git last";
    gclean = "git cleanup";
  };

  # lazygit
  programs.lazygit = {
    enable = true;
  };
}
