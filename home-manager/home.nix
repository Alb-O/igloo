# Home Manager configuration
# Main entry point for user environment configuration
{
  pkgs,
  inputs,
  globals,
  ...
}: {
  # Import modular configuration
  imports = [
    # Custom modules
    (import ./modules {inherit inputs globals;})

    # Example external modules (commented out):
    # outputs.homeManagerModules.example
    # inputs.nix-colors.homeManagerModules.default
  ];

  # Basic user information
  home = {
    username = globals.user.username;
    homeDirectory = globals.user.homeDirectory;
  };

  # User packages
  home.packages = with pkgs.unstable;
    [
      # General
      jq
      ufetch
      git
      gh
      unipicker
      hyprpicker
      xdg-ninja
      lm_sensors
      ffmpeg
      yt-dlp
      fzf
      ripgrep
      yazi
      unison
      zoxide
      bat
      rucola
      meowpdf
      chawan
      poppler-utils
      ungoogled-chromium
      hydrus
      # Development
      nodejs
      gcc
      # Clipboard
      wl-clipboard
      cliphist
    ]
    ++ [
      # Custom packages
      pkgs.blender-daily

      # npm globlal packages
      (pkgs.writeShellApplication {
        name = "claude";
        runtimeInputs = [pkgs.nodejs];
        text = ''
          exec ${pkgs.nodejs}/bin/npx -y @anthropic-ai/claude-code "$@"
        '';
      })
      (pkgs.writeShellApplication {
        name = "codex";
        runtimeInputs = [pkgs.nodejs];
        text = ''
          exec ${pkgs.nodejs}/bin/npx -y @openai/codex "$@"
        '';
      })
      (pkgs.writeShellApplication {
        name = "gemini";
        runtimeInputs = [pkgs.nodejs];
        text = ''
          exec ${pkgs.nodejs}/bin/npx -y @google/gemini-cli "$@"
        '';
      })
      (pkgs.writeShellApplication {
        name = "qwen";
        runtimeInputs = [pkgs.nodejs];
        text = ''
          exec ${pkgs.nodejs}/bin/npx -y @qwen-code/qwen-code "$@"
        '';
      })
    ];

  # State version - don't change this
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = globals.system.stateVersion;
}
