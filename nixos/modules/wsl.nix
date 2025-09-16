{ lib, pkgs, ... }:
let
  isWSL =
    builtins.pathExists /proc/version
    && builtins.match ".*[Mm]icrosoft.*" (builtins.readFile /proc/version) != null;
in
{
  config = lib.mkIf isWSL {
    environment.systemPackages = [ pkgs.wslu ];

    environment.shellAliases = {
      open = "wslview";
      explorer = "wslview";
      pbcopy = "/mnt/c/Windows/System32/clip.exe";
      pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command Get-Clipboard";
    };

    environment.variables = {
      IS_WSL = "true";
      WSL_DISTRO_NAME = lib.mkDefault "NixOS";
      BROWSER = lib.mkDefault "wslview";
    };
  };
}
