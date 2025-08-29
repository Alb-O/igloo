{ pkgs, lib, config, ... }: {
  options.igloo.yazi.enable =
    lib.mkEnableOption "Enable yazi file manager with sane defaults"
    // {
      default = true;
    };

  config = lib.mkIf config.igloo.yazi.enable {
    programs.yazi = {
      enable = true;

      flavors = {
        tokyo-night = pkgs.fetchFromGitHub {
          owner = "BennyOe";
          repo = "tokyo-night.yazi";
          rev = "main";
          sha256 = "4aNPlO5aXP8c7vks6bTlLCuyUQZ4Hx3GWtGlRmbhdto=";
        };
      };

      settings = {
        yazi = {
          manager = {
            show_hidden = false;
            show_symlink = true;
            sort_by = "natural";
            sort_sensitive = false;
            sort_reverse = false;
            sort_dir_first = true;
          };
        };

        theme = {
          status = {
            sep_left = {
              open = "";
              close = "";
            };
            sep_right = {
              open = "";
              close = "";
            };
          };
        };
      };
    };

    # Create theme.toml separately to use the flavor
    home.file.".config/yazi/theme.toml".text = ''
      [flavor]
      dark = "tokyo-night"

      [status]
      sep_left = { open = "", close = "" }
      sep_right = { open = "", close = "" }
    '';
  };
}
