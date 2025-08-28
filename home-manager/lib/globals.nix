{
  env,
}: let
  homeDir = "/home/${env.username}";
  configDir = "${homeDir}/.config/home-manager";
in {
  user = {
    username = env.username;
    name = env.fullName;
    email = env.email;
    homeDirectory = homeDir;
  };

  system = {
    hostname = env.hostname;
    architecture = "x86_64-linux";
    stateVersion = "25.05";
    isGraphical = env.isGraphical;
  };

  dirs = {
    localBin = "${homeDir}/.local/bin";
    localShare = "${homeDir}/.local/share";
    cargoBin = "${homeDir}/.local/share/cargo/bin";
    configRoot = configDir;
  };

  # Default applications
  editor = "nvim";
  terminal = "kitty";
  browser = "firefox";
}
