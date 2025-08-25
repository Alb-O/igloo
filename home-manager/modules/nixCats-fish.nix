{
  config,
  lib,
  inputs,
  globals,
  ...
}: {
  options.igloo.nixCats-fish.enable =
    lib.mkEnableOption "Enable nixCats-fish shell"
    // {
      default = false;
    };

  config = lib.mkIf config.igloo.nixCats-fish.enable {
    # Import the nixCats-fish Home Manager module
    imports = [
      inputs.nixCats-fish.homeModules.default
    ];

    # Enable nixCats-fish
    programs.nixCats-fish = {
      enable = true;
      seedConfig = true;
      # Optionally set as default shell - uncomment if desired
      # setAsDefaultShell = true;
    };

    # Set environment variable to point to repo config for live editing
    home.sessionVariables = lib.mkIf (config.igloo.nixCats-fish.enable) {
      NIXCATS_FISH_DIR = "${globals.user.homeDirectory}/dev/igloo/flakes/nixCats-fish/config";
    };
  };
}
