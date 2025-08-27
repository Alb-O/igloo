# Home Manager WSL integration module
{
  pkgs,
  lib,
  config,
  globals,
  ...
}: let
  # Detect WSL environment
  isWSL =
    (builtins.getEnv "WSL_DISTRO_NAME")
    != ""
    || (builtins.getEnv "WSLENV") != ""
    || (builtins.getEnv "IS_WSL") == "true";

  # Windows clipboard integration
  windowsClipboard = pkgs.writeShellScriptBin "wsl-clipboard" ''
    #!/bin/bash
    # Smart clipboard integration for WSL

    clip_copy() {
      if command -v /mnt/c/Windows/System32/clip.exe >/dev/null 2>&1; then
        # Convert line endings to Windows format for clip.exe
        sed 's/$/\r/' | /mnt/c/Windows/System32/clip.exe
      else
        echo "Windows clipboard not available" >&2
        return 1
      fi
    }

    clip_paste() {
      if command -v /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe >/dev/null 2>&1; then
        /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Get-Clipboard" 2>/dev/null | sed 's/\r$//'
      elif command -v /mnt/c/Windows/System32/cmd.exe >/dev/null 2>&1; then
        # Fallback using cmd if PowerShell isn't available
        /mnt/c/Windows/System32/cmd.exe /c "echo.|clip && timeout 1 > nul && echo off && for /f \"delims=\" %i in ('powershell -command \"Get-Clipboard\"') do @echo %i" 2>/dev/null
      else
        echo "Windows PowerShell not available" >&2
        return 1
      fi
    }

    case "''${1:-copy}" in
      copy|c)
        if [ -p /dev/stdin ]; then
          clip_copy
        else
          echo "Usage: echo 'text' | wsl-clipboard copy" >&2
          exit 1
        fi
        ;;
      paste|p) clip_paste ;;
      *) echo "Usage: wsl-clipboard [copy|paste]" >&2; exit 1 ;;
    esac
  '';
in {
  options.igloo.wsl.enable =
    lib.mkEnableOption "Enable WSL integration features"
    // {
      default = isWSL;
    };

  config = lib.mkIf config.igloo.wsl.enable {
    home.packages = [
      windowsClipboard
    ];

    # WSL-specific environment variables
    home.sessionVariables = {
      # Ensure we can detect WSL in nested shells
      IS_WSL = "true";

      # Set WSL-friendly browser
      BROWSER = lib.mkDefault "/mnt/c/Windows/System32/cmd.exe /c start";

      # Configure editor to work with Windows paths
      EDITOR = lib.mkDefault "hx";
    };

    # Enhanced shell aliases for WSL
    home.shellAliases = {
      # Clipboard operations
      "pbcopy" = "${windowsClipboard}/bin/wsl-clipboard copy";
      "pbpaste" = "${windowsClipboard}/bin/wsl-clipboard paste";
      "clip" = "${windowsClipboard}/bin/wsl-clipboard copy";

      # Windows integration
      "open" = ''f() { /mnt/c/Windows/System32/cmd.exe /c start "$(wslpath -w "$1")" 2>/dev/null & }; f'';
      "explorer" = ''f() { /mnt/c/Windows/explorer.exe "$(wslpath -w "''${1:-.}")" 2>/dev/null & }; f'';
      "notepad" = ''f() { /mnt/c/Windows/System32/notepad.exe "$(wslpath -w "$1")" 2>/dev/null & }; f'';

      # Quick Windows navigation
      "cdhome" = "cd /mnt/c/Users/$USER";
      "cddownloads" = "cd /mnt/c/Users/$USER/Downloads";
      "cddesktop" = "cd /mnt/c/Users/$USER/Desktop";
      "cddocuments" = "cd /mnt/c/Users/$USER/Documents";

      # Windows tools
      "cmd" = "/mnt/c/Windows/System32/cmd.exe";
      "powershell" = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe";
      "pwsh" = "powershell.exe"; # Modern PowerShell if installed
    };

    # Git configuration for WSL
    programs.git = lib.mkIf config.programs.git.enable {
      extraConfig = {
        # Handle line endings properly in WSL
        core.autocrlf = false;
        core.eol = "lf";

        # Performance optimization for Windows filesystem
        core.preloadindex = true;
        core.fscache = true;

        # Credential helper for Windows
        credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
      };
    };
  };
}
