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
    ./shell.nix
    ./ssh.nix
    ./broot
    ./git.nix
    ./tmux.nix
    ./codex.nix
    ./geminicommit.nix
    ./helix.nix
  ]
  ++ (
    if globals.system.isGraphical then
      [
        ./niri
        ./fuzzel.nix
        ./swww.nix
        ./gtk.nix
        ./mako.nix
        ./firefox
        ./vscode.nix
        ./sillytavern.nix
        ./alacritty.nix
        ./polkit.nix
        ./clipboard.nix
      ]
    else
      [
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
    profileExtra = ''
      # Fix for XDG-compliant home-manager session vars
      if [ -f "$HOME/.local/state/nix/profiles/home-manager/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.local/state/nix/profiles/home-manager/etc/profile.d/hm-session-vars.sh"
      fi
    '';
  };
  
  # Use standard home-manager session variables
  home.sessionPath = [
    globals.dirs.localBin
    globals.dirs.cargoBin
  ];
  home.sessionVariables = builtins.removeAttrs globals.env [
    "EMAIL"
    "NAME"
  ];
}
