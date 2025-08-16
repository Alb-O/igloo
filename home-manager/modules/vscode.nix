{pkgs, ...}: let
  fonts = import ../../lib/fonts.nix pkgs;
in {
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;

    mutableExtensionsDir = true;

    profiles.default.extensions = with pkgs.vscode-marketplace; [
      # Language support
      ms-python.python
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      yzhang.markdown-all-in-one

      # Git integration
      eamodio.gitlens

      # Nix integration
      arrterian.nix-env-selector
      jnoortheen.nix-ide

      # Productivity and diagnostics
      usernamehw.errorlens

      # AI and code assistance
      anthropic.claude-code
      kilocode.kilo-code
      saoudrizwan.claude-dev
      github.copilot
      pkgs.nix-vscode-extensions.vscode-marketplace-release.github.copilot-chat

      # Icons
      pkief.material-icon-theme
      pkief.material-product-icons

      # Theme
      ms-vscode.cpptools-themes

      # License management
      ultram4rine.vscode-choosealicense
    ];

    # Declarative settings.json configuration
    profiles.default.userSettings = {
      # Font configuration - Global mono font
      "editor.fontFamily" = "'${fonts.mono.name}', 'monospace'";
      "editor.fontSize" = fonts.mono.size.large;
      "editor.fontLigatures" = true;
      "editor.lineHeight" = 1.5;

      # Terminal configuration
      "terminal.integrated.fontFamily" = "'${fonts.mono.name}'";
      "terminal.integrated.fontSize" = fonts.mono.size.normal;
      "terminal.integrated.smoothScrolling" = true;

      # Editor behavior
      "editor.lineNumbers" = "on";
      "editor.renderWhitespace" = "boundary";
      "editor.wordWrap" = "on";
      "editor.minimap.enabled" = true;
      "editor.cursorBlinking" = "smooth";
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.smoothScrolling" = true;
      "editor.formatOnSave" = true;
      "editor.formatOnPaste" = true;
      "editor.autoIndentOnPaste" = true;

      # File handling
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;

      # Theme and appearance
      "workbench.colorTheme" = "2017 Dark (Visual Studio - C/C++)";
      "workbench.preferredDarkColorTheme" = "";
      "workbench.startupEditor" = "welcomePage";
      "workbench.productIconTheme" = "material-product-icons";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.activityBar.location" = "top";
      "window.commandCenter" = false;
      "workbench.list.smoothScrolling" = true;

      # Git integration
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
      "git.autofetch" = true;

      # Language-specific settings
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";

      # Rust configuration
      "rust-analyzer.checkOnSave.command" = "clippy";
      "rust-analyzer.cargo.allFeatures" = true;

      # Python configuration
      "python.defaultInterpreterPath" = "/usr/bin/python3";
      "python.linting.enabled" = true;
      "python.linting.pylintEnabled" = true;
      "python.formatting.provider" = "black";

      # Extension settings
      "errorLens.enabledDiagnosticLevels" = [
        "error"
        "warning"
        "info"
      ];

      # Telemetry and updates - disable to prevent conflicts with Nix management
      "telemetry.telemetryLevel" = "off";
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;
    };

    # Custom keybindings
    profiles.default.keybindings = [
      {
        key = "ctrl+shift+p";
        command = "workbench.action.showCommands";
      }
      {
        key = "ctrl+`";
        command = "workbench.action.terminal.toggleTerminal";
      }
    ];
  };
}
