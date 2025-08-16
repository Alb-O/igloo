# Niri Wayland Compositor Configuration
# Declarative configuration using niri-flake's programs.niri.settings
{
  config,
  pkgs,
  globals,
  ...
}: let
  colors = import ../../../lib/themes;

  # Import modular configurations
  inputConfig = import ./input.nix;
  outputsConfig = import ./outputs.nix;
  layoutConfig = import ./layout.nix {inherit colors;};
  bindsConfig = import ./binds.nix {
    inherit config pkgs globals;
  };
  windowRulesConfig = import ./window-rules.nix;
  miscConfig = import ./misc.nix;
in {
  programs.niri = {
    settings =
      inputConfig // outputsConfig // layoutConfig // bindsConfig // windowRulesConfig // miscConfig;
  };
}
