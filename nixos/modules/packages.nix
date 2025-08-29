# System-wide packages and fonts configuration
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Essential tools
    wget
    just
    firefox
    kitty
    alacritty
    neovim
  ];
}
