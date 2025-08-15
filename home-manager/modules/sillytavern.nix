# SillyTavern LLM frontend configuration
{
  pkgs,
  globals,
  ...
}:
{
  # Package installation
  home.packages = with pkgs.unstable; [
    sillytavern
  ];

  # Create SillyTavern wrapper script
  home.file.".local/bin/sillytavern-start" = {
    text = ''
      #!${pkgs.bash}/bin/bash
      export SILLYTAVERN_DATAROOT="${globals.dirs.localShare}/sillytavern"
      mkdir -p "$SILLYTAVERN_DATAROOT"
      cd ${pkgs.unstable.sillytavern}/opt/sillytavern
      exec ${pkgs.nodejs}/bin/node server.js "$@"
    '';
    executable = true;
  };

  # Desktop application entry
  xdg.desktopEntries = {
    sillytavern = {
      name = "SillyTavern";
      comment = "LLM Frontend for Power Users";
      icon = "applications-games"; # Generic game icon, can be customized
      exec = "kitty ${globals.dirs.localBin}/sillytavern-start";
      categories = [
        "Network"
        "Chat"
        "Development"
      ];
      terminal = true;
      type = "Application";
      startupNotify = true;
    };
  };
}
