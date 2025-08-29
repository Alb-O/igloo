{ pkgs, config, lib, ... }: {
  options.igloo.bash.enable =
    lib.mkEnableOption "Enable Bash configuration"
    // {
      default = true;
    };

  config = {
    # Enable the bash module with default settings
    igloo.bash = {
      enable = lib.mkDefault true;
    };

    # Disable HM-managed Bash init files; we'll handle everything via ~/.profile
    programs.bash.enable = lib.mkIf config.igloo.bash.enable (lib.mkForce false);

  };
}
