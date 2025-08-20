{ pkgs, globals }:
let
  # Detect WSL environment
  isWSL = (builtins.getEnv "WSL_DISTRO_NAME") != "" || 
          (builtins.getEnv "WSLENV") != "" ||
          (builtins.getEnv "IS_WSL") == "true";

  copyBin = if globals.system.isGraphical then
    pkgs.writeShellScriptBin "igloo-copy" ''
      exec ${pkgs.wl-clipboard}/bin/wl-copy "$@"
    ''
  else if isWSL then
    pkgs.writeShellScriptBin "igloo-copy" ''
      # Use Windows clipboard in WSL
      if command -v /mnt/c/Windows/System32/clip.exe >/dev/null 2>&1; then
        exec /mnt/c/Windows/System32/clip.exe
      else
        # Fallback to consuming input if Windows clipboard not available
        exec ${pkgs.coreutils}/bin/cat > /dev/null
      fi
    ''
  else
    pkgs.writeShellScriptBin "igloo-copy" ''
      # Consume stdin safely when no graphical clipboard is available
      exec ${pkgs.coreutils}/bin/cat > /dev/null
    '';
in rec {
  # Whether we are in a graphical environment
  isGraphical = globals.system.isGraphical;

  # Clipboard command (always present). In headless, it discards input.
  copyCmd = "${copyBin}/bin/igloo-copy";

  # Screen lock command; noop on headless
  lockCmd = if isGraphical then
    "${pkgs.swaylock}/bin/swaylock"
  else
    "${pkgs.coreutils}/bin/true";

  # Power off monitors via niri; noop on headless
  powerOffMonitorsCmd = if isGraphical then
    "${pkgs.niri}/bin/niri msg action power-off-monitors"
  else
    "${pkgs.coreutils}/bin/true";
}

