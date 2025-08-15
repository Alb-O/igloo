{ pkgs, ... }:
{
  home.packages = with pkgs; [
    broot
  ];

  xdg.configFile."broot/conf.hjson".source = ./conf.hjson;

  # Download and install the vscode font for broot icons
  home.file.".local/share/fonts/vscode.ttf".source = pkgs.fetchurl {
    url = "https://github.com/Canop/broot/raw/main/resources/icons/vscode/vscode.ttf";
    sha256 = "0ddk5sf25qaqw9azv1azcg0zssfcggmzjm564i69ngz3w9j0nx9a";
  };
}
