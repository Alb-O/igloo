# Home Manager modules aggregation
{ lib, inputs, user, host, ... }:
let
  homeDir = user.homeDirectory;
  dirs = {
    localBin = "${homeDir}/.local/bin";
    localShare = "${homeDir}/.local/share";
    cargoBin = "${homeDir}/.local/share/cargo/bin";
  };
  prefs = {
    editor = "kak";
    terminal = "wezterm";
    browser = "firefox";
  };

  # Auto-import modules from ../../modules/{programs,services}
  modulesRoot = ./.;
  programsDir = modulesRoot + "/programs";
  servicesDir = modulesRoot + "/services";

  listModules = dir:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
    in
      builtins.concatMap (
        name:
          let
            type = entries.${name};
            path = dir + "/${name}";
          in
            if lib.strings.hasPrefix "_" name then []
            else if type == "regular" && lib.strings.hasSuffix ".nix" name then [ path ]
            else if type == "directory" then [ path ]
            else []
      ) names;

  autoImports =
    (if builtins.pathExists programsDir then listModules programsDir else [])
    ++ (if builtins.pathExists servicesDir then listModules servicesDir else []);
in
{
  _module.args = {
    inherit inputs user host dirs prefs;
  };

  imports =
    [
      ./xdg.nix
      ../lib/fonts.nix
    ]
    ++ (
      if host.isGraphical then
        [ inputs.www.homeModules.firefox ]
      else
        [ inputs.www.homeModules.wsl ]
    )
    ++ autoImports;

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
