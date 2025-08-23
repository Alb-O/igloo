{
  username,
  name,
  email,
  hostname,
  architecture ? "x86_64-linux",
  stateVersion ? "25.05",
  isGraphical ? true,
}: let
  homeDir = "/home/${username}";
  configDir = "${homeDir}/.config/home-manager";
in {
  user = {
    inherit username name email;
    homeDirectory = homeDir;
  };

  system = {
    inherit
      hostname
      architecture
      stateVersion
      isGraphical
      ;
  };

  dirs = {
    localBin = "${homeDir}/.local/bin";
    localShare = "${homeDir}/.local/share";
    cargoBin = "${homeDir}/.local/share/cargo/bin";
    configRoot = configDir;
  };

  # Default applications
  editor = "nvim";
  terminal = "foot";
  browser = "firefox";
}
