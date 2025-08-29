{ pkgs, config, lib, ... }: {
  options.igloo.fish.enable =
    lib.mkEnableOption "Enable Fish shell configuration"
    // {
      default = true;
    };

  config = lib.mkIf config.igloo.fish.enable {
    # Enable fish shell with home-manager configuration
    programs.fish.enable = true;
    
    # Fish will be launched by .profile for interactive sessions
    programs.fish.shellInit = ''
      # Fish-specific initialization
      set -gx SHELL (which fish)
    '';
  };
}
