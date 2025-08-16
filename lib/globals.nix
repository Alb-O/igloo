{
  username ? null,
  name ? null,
  email ? null,
  hostname ? null,
  architecture ? "x86_64-linux",
  stateVersion ? "25.05",
  isGraphical ? true,
}: let
  bootstrap = import ./bootstrap.nix;
  finalUsername =
    if username != null
    then username
    else bootstrap.env.USERNAME;
  finalName =
    if name != null
    then name
    else bootstrap.env.NAME;
  finalEmail =
    if email != null
    then email
    else bootstrap.env.EMAIL;
  finalHostname =
    if hostname != null
    then hostname
    else bootstrap.env.HOSTNAME;

  homeDir = "/home/${finalUsername}";
  actualProjectRoot = bootstrap.actualProjectPath;
in {
  gtkTheme = bootstrap.env.GTK_THEME or "Adwaita-dark";
  iconTheme = bootstrap.env.ICON_THEME or "Adwaita";
  cursorTheme = bootstrap.env.CURSOR_THEME or "Adwaita";

  user = {
    username = finalUsername;
    name = finalName;
    email = finalEmail;
    homeDirectory = homeDir;
  };

  system = {
    hostname = finalHostname;
    inherit
      architecture
      stateVersion
      isGraphical
      ;
  };

  dirs = {
    localBin = "${homeDir}/.local/bin";
    localShare = "${homeDir}/.local/share";
    scripts = "${actualProjectRoot}/scripts";
    cargoBin = "${homeDir}/.local/share/cargo/bin";
    projectRoot = actualProjectRoot;
  };

  env = bootstrap.env;
}
