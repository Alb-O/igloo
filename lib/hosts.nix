# Host profile definitions
# Generic host configurations without personal info
{
  # General desktop profile
  desktop = {
    hostname = let
      h = builtins.getEnv "HOSTNAME";
    in
      if h != ""
      then h
      else "desktop";
    stateVersion = "24.11";
    isGraphical = true;
    architecture = "x86_64-linux";
    profile = "desktop";
  };

  # Server/WSL profile
  server = {
    hostname = let
      h = builtins.getEnv "HOSTNAME";
    in
      if h != ""
      then h
      else "nixos";
    stateVersion = "24.11";
    isGraphical = false;
    architecture = "x86_64-linux";
    profile = "server";
  };
}
