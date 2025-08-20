# Home Manager modules aggregation
{
  inputs,
  globals,
  ...
}:
{
  _module.args = { inherit inputs globals; };
  imports = [
    ./xdg.nix
    ./shell/bash.nix
    ./ssh.nix
    ./broot
    ./git.nix
    ./tmux
    ./zoxide.nix
    ./fzf.nix
    ./codex.nix
    ./helix.nix
    ./languages
    ./wsl.nix
  ]
  ++ (
    if globals.system.isGraphical then
      [
        ./niri
        ./swww.nix
        ./mako.nix
        ./firefox
        ./sillytavern.nix
        ./foot.nix
        ./polkit.nix
        ./clipboard.nix
      ]
    else
      [
        ./firefox/wsl.nix
      ]
  );

  programs.home-manager.enable = true;

  # Use standard home-manager session variables
  home.sessionPath = [
    globals.dirs.localBin
    globals.dirs.cargoBin
  ];

  home.sessionVariables = {
    USERNAME = globals.user.username;
    HOSTNAME = globals.system.hostname;
    EDITOR = globals.editor;
    TERMINAL = globals.terminal;
    TERM = globals.terminal;
    BROWSER = globals.browser;
  };
}
