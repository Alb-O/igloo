# Home Manager modules aggregation
{
  inputs,
  globals,
  ...
}: {
  _module.args = {inherit inputs globals;};
  imports =
    [
      ./xdg.nix
      ./shell.nix
      ./ssh.nix
      ./broot
      ./git.nix
      ./neovim
      ./codex.nix
      ./geminicommit.nix
    ]
    ++ (
      if globals.system.isGraphical
      then [
        ./niri
        ./fuzzel.nix
        ./swww.nix
        ./gtk.nix
        ./mako.nix
        ./firefox
        ./vscode.nix
        ./sillytavern.nix
        ./kitty.nix
        ./polkit.nix
        ./clipboard.nix
      ]
      else [
        ./firefox/wsl.nix
      ]
    );

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = false;
    historySize = 0;
    historyFileSize = 0;
    bashrcExtra = "";
    initExtra = ''
      [[ $- == *i* ]] && [[ -z "$IN_NIX_SHELL" ]] && exec fish
    '';
    profileExtra = "";
  };
  home.sessionPath = [
    globals.dirs.localBin
    globals.dirs.cargoBin
  ];

  home.sessionVariables = builtins.removeAttrs globals.env [
    "EMAIL"
    "NAME"
  ];
}
