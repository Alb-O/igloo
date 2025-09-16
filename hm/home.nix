# Home Manager configuration
# Main entry point for user environment configuration
{
  pkgs,
  lib,
  inputs,
  user,
  host,
  ...
}:
{
  # Import modular configuration
  imports = [
    # Custom modules
    ./mod

    # Example external modules (commented out):
    # outputs.homeManagerModules.example
    # inputs.nix-colors.homeManagerModules.default
  ];

  # Basic user information
  home = {
    username = user.username;
    homeDirectory = user.homeDirectory;
  };

  # User packages
  home.packages =
    with pkgs.unstable;
    [
      # CLI Tools (always included)
      gh
      unzip
      lm_sensors
      ffmpeg
      yt-dlp
      atuin
      unison
      rucola
      onefetch
      poppler-utils
      unipicker
      nodejs
      gcc
      gnumake
    ]
    ++ lib.optionals host.isGraphical [
      # Graphical Tools (only when isGraphical = true)
      hyprpicker
      vesktop
      xdg-desktop-portal-termfilechooser
      # Clipboard tools for Wayland
      wl-clipboard
      cliphist
      # Input configuration
      solaar
      libinput
    ];

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [ "--cmd" "cd" ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*".addKeysToAgent = "yes";
  };

  programs.git = {
    enable = true;
    userName = user.name;
    userEmail = user.email;
    lfs.enable = true;
    aliases = {
      undo = "reset --soft HEAD~1";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";
      branches = "branch -a";
      remotes = "remote -v";
    };
    ignores = [
      ".DS_Store"
      "Thumbs.db"
      "*~"
      "*.swp"
      "*.tmp"
      "node_modules/"
      "dist/"
      "build/"
      "target/"
      "result"
      "result-*"
    ];
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = false;
        safecrlf = true;
        filemode = true;
      };
      pull = {
        rebase = false;
        ff = "only";
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      merge = {
        ff = false;
        conflictstyle = "diff3";
      };
      rebase = {
        autostash = true;
        autosquash = true;
      };
      diff = {
        algorithm = "patience";
        renames = "copies";
        mnemonicPrefix = true;
      };
      status = {
        showUntrackedFiles = "all";
        submoduleSummary = true;
      };
      color = {
        ui = "auto";
        branch = "auto";
        diff = "auto";
        status = "auto";
      };
      help.autocorrect = 1;
      rerere.enabled = true;
      log.date = "relative";
      credential."https://github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
      credential."https://gist.github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
    };
  };

  # State version - don't change this
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = host.stateVersion;

  programs.bash.enable = true;
  home.file.".config/bash/profile" = {
    source = ./dotfiles/bash/profile.sh;
  };

  programs.bash.profileExtra = ''
    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    if [ -r "$XDG_CONFIG_HOME/bash/profile" ]; then
      # shellcheck disable=SC1090
      . "$XDG_CONFIG_HOME/bash/profile"
    fi
  '';
}
