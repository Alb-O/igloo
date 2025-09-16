# Home Manager modules aggregation
{
  inputs,
  user,
  host,
  ...
}:
let
  homeDir = user.homeDirectory;
  dirs = {
    localBin = "${homeDir}/.local/bin";
    localShare = "${homeDir}/.local/share";
    cargoBin = "${homeDir}/.local/share/cargo/bin";
  };
  prefs = {
    editor = "nvim";
    terminal = "kitty";
    browser = "firefox";
  };
in
{
  _module.args = {
    inherit
      inputs
      user
      host
      dirs
      prefs
      ;
  };
  imports = [
    ./xdg.nix
    ../lib/fonts.nix
    ./bash
    ./shell-tools.nix
    ./mako.nix
    ./git.nix
    ./yazi
    ./fish
  ]
  ++ (
    if host.isGraphical then
      [
        inputs.www.homeModules.firefox
        ./sillytavern.nix
        ./polkit.nix
        ./clipboard.nix
      ]
    else
      [
        inputs.www.homeModules.wsl
      ]
  );

  programs.home-manager.enable = true;

  # Use standard home-manager session variables
  home.sessionPath = [
    dirs.localBin
    dirs.cargoBin
  ];

  home.sessionVariables = {
    USERNAME = user.username;
    HOSTNAME = host.hostname;
    EDITOR = prefs.editor;
    TERMINAL = prefs.terminal;
    TERM = prefs.terminal;
    BROWSER = prefs.browser;
  };

  accounts = {
    calendar.basePath = ".local/share/calendars";
    contact.basePath = ".local/share/contacts";
  };
}
