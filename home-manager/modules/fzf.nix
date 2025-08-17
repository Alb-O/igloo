{ pkgs, ... }:
{
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--tmux"
      "border-native"
    ];
  };
}