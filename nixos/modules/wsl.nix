# WSL-specific module for enhanced Windows interoperability
{ pkgs, lib, config, ... }:

let
  # Detect if we're running in WSL
  isWSL = builtins.pathExists /proc/version &&
          builtins.match ".*[Mm]icrosoft.*" (builtins.readFile /proc/version) != null;

  # Create a script to filter and clean Windows PATH
  pathFilter = pkgs.writeShellScriptBin "wsl-path-filter" ''
    # Filter Windows PATH to only include useful directories
    # This removes bloat while keeping essential Windows tools
    
    ORIGINAL_PATH="$1"
    FILTERED_PATH=""
    
    # Essential Windows directories we want to keep
    KEEP_PATHS=(
      "/mnt/c/Windows/System32"
      "/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
      "/mnt/c/Windows/System32/OpenSSH"
      "/mnt/c/Program Files/Git/bin"
      "/mnt/c/Program Files/Git/cmd"
      "/mnt/c/Program Files/Docker/Docker/resources/bin"
      "/mnt/c/Program Files/PowerShell"
      "/mnt/c/Users/.*/AppData/Local/Programs/Microsoft VS Code/bin"
    )
    
    # Split PATH and filter
    IFS=':' read -ra PATH_ARRAY <<< "$ORIGINAL_PATH"
    for path in "''${PATH_ARRAY[@]}"; do
      # Skip if path doesn't start with /mnt/c
      [[ "$path" != /mnt/c/* ]] && continue
      
      # Check if this path matches our keep list
      for keep_pattern in "''${KEEP_PATHS[@]}"; do
        if [[ "$path" =~ $keep_pattern ]]; then
          if [ -d "$path" ]; then
            if [ -n "$FILTERED_PATH" ]; then
              FILTERED_PATH="$FILTERED_PATH:$path"
            else
              FILTERED_PATH="$path"
            fi
          fi
          break
        fi
      done
    done
    
    echo "$FILTERED_PATH"
  '';

  # Windows integration utilities
  winUtils = pkgs.writeShellScriptBin "wsl-win-utils" ''
    #!/bin/bash
    
    # Open Windows file explorer to current directory
    win-explorer() {
      local path="''${1:-.}"
      /mnt/c/Windows/explorer.exe "$(wslpath -w "$path")" 2>/dev/null &
    }
    
    # Open file with default Windows program
    win-open() {
      local file="$1"
      if [ -f "$file" ]; then
        /mnt/c/Windows/System32/cmd.exe /c start "$(wslpath -w "$file")" 2>/dev/null &
      else
        echo "File not found: $file"
        return 1
      fi
    }
    
    # Copy text to Windows clipboard
    win-clip() {
      if [ -p /dev/stdin ]; then
        cat | /mnt/c/Windows/System32/clip.exe
      else
        echo "$*" | /mnt/c/Windows/System32/clip.exe
      fi
    }
    
    # Get Windows username
    win-user() {
      /mnt/c/Windows/System32/cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n'
    }
    
    # Convert WSL path to Windows path
    win-path() {
      wslpath -w "$1" 2>/dev/null
    }
    
    # Convert Windows path to WSL path  
    wsl-path() {
      wslpath -u "$1" 2>/dev/null
    }
    
    # Export functions
    export -f win-explorer win-open win-clip win-user win-path wsl-path
  '';

in {
  config = lib.mkIf isWSL {
    # Add WSL utilities to system packages
    environment.systemPackages = [
      pathFilter
      winUtils
    ];

    # Source the Windows utilities in shell sessions
    environment.interactiveShellInit = ''
      # Source WSL Windows utilities
      source ${winUtils}/bin/wsl-win-utils
      
      # Filter Windows PATH if it exists
      if [[ ":$PATH:" == *":/mnt/c/"* ]]; then
        WIN_PATH=$(echo "$PATH" | tr ':' '\n' | grep '^/mnt/c/' | tr '\n' ':' | sed 's/:$//')
        if [ -n "$WIN_PATH" ]; then
          FILTERED_WIN_PATH=$(${pathFilter}/bin/wsl-path-filter "$WIN_PATH")
          # Remove old Windows paths and add filtered ones
          CLEAN_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '^/mnt/c/' | tr '\n' ':' | sed 's/:$//')
          if [ -n "$FILTERED_WIN_PATH" ]; then
            export PATH="$CLEAN_PATH:$FILTERED_WIN_PATH"
          else
            export PATH="$CLEAN_PATH"
          fi
        fi
      fi
    '';

    # Enhanced shell aliases for WSL
    environment.shellAliases = {
      # Clipboard integration with better naming
      "pbcopy" = "win-clip";
      "pbpaste" = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command Get-Clipboard";
      
      # File operations
      "open" = "win-open";
      "explorer" = "win-explorer";
      
      # Quick navigation to common Windows locations
      "cdwin" = "cd /mnt/c";
      "cdhome" = "cd /mnt/c/Users/$(win-user)";
      "cddesktop" = "cd /mnt/c/Users/$(win-user)/Desktop";
      "cddownloads" = "cd /mnt/c/Users/$(win-user)/Downloads";
      "cddocuments" = "cd /mnt/c/Users/$(win-user)/Documents";
    };

    # Set environment variables for better integration
    environment.variables = {
      # WSL identification
      WSL_DISTRO_NAME = lib.mkDefault "NixOS";
      IS_WSL = "true";
      
      # Browser integration
      BROWSER = lib.mkDefault "/mnt/c/Windows/System32/cmd.exe /c start";
      
      # Windows paths
      WINDOWS_HOME = "/mnt/c/Users/$(${winUtils}/bin/wsl-win-utils; win-user)";
    };
  };
}