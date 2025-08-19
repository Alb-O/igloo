{ pkgs, globals }:
let
  copyBin = if globals.system.isGraphical then
    pkgs.writeShellScriptBin "igloo-copy" ''
      exec ${pkgs.wl-clipboard}/bin/wl-copy "$@"
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

