{
  # General desktop profile
  desktop = {
    hostname = "desktop";
    stateVersion = "24.11";
    isGraphical = true;
    architecture = "x86_64-linux";
    profile = "desktop";
    timeZone = "UTC";
    locale = "en_US.UTF-8";
  };

  # Server/WSL profile
  server = {
    hostname = "server";
    stateVersion = "24.11";
    isGraphical = false;
    architecture = "x86_64-linux";
    profile = "server";
    timeZone = "UTC";
    locale = "en_US.UTF-8";
  };
}
