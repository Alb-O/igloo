{
  pkgs,
  lib,
  globals,
  config,
  ...
}: {
  options.igloo.yazi.enable =
    lib.mkEnableOption "Enable yazi file manager with sane defaults"
    // {
      default = true;
    };

  config = lib.mkIf config.igloo.yazi.enable {
    programs.yazi = {
      enable = true;
      
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
          manager = {
            cwd = { fg = "#7dcfff"; };
            hovered = { fg = "#1a1b26"; bg = "#7aa2f7"; };
            preview_hovered = { underline = true; };
            find_keyword = { fg = "#9ece6a"; italic = true; };
            find_position = { fg = "#f7768e"; bg = "reset"; italic = true; };
            marker_selected = { fg = "#9ece6a"; bg = "#9ece6a"; };
            marker_copied = { fg = "#e0af68"; bg = "#e0af68"; };
            marker_cut = { fg = "#f7768e"; bg = "#f7768e"; };
            tab_active = { fg = "#c0caf5"; bg = "#1a1b26"; };
            tab_inactive = { fg = "#565f89"; bg = "#1a1b26"; };
            border_symbol = "│";
            border_style = { fg = "#565f89"; };
          };
          
          status = {
            separator_open = "";
            separator_close = "";
            separator_style = { fg = "#565f89"; bg = "#565f89"; };
            mode_normal = { fg = "#1a1b26"; bg = "#7aa2f7"; bold = true; };
            mode_select = { fg = "#1a1b26"; bg = "#9ece6a"; bold = true; };
            mode_unset = { fg = "#1a1b26"; bg = "#f7768e"; bold = true; };
            progress_label = { fg = "#c0caf5"; bold = true; };
            progress_normal = { fg = "#7aa2f7"; bg = "#292e42"; };
            progress_error = { fg = "#f7768e"; bg = "#292e42"; };
            permissions_t = { fg = "#9ece6a"; };
            permissions_r = { fg = "#e0af68"; };
            permissions_w = { fg = "#f7768e"; };
            permissions_x = { fg = "#7dcfff"; };
            permissions_s = { fg = "#bb9af7"; };
          };
          
          select = {
            border = { fg = "#7aa2f7"; };
            active = { fg = "#f7768e"; };
            inactive = { fg = "#565f89"; };
          };
          
          input = {
            border = { fg = "#7aa2f7"; };
            title = { fg = "#c0caf5"; };
            value = { fg = "#c0caf5"; };
            selected = { reversed = true; };
          };
          
          completion = {
            border = { fg = "#7aa2f7"; };
            active = { bg = "#292e42"; };
            inactive = { }; 
          };
          
          tasks = {
            border = { fg = "#7aa2f7"; };
            title = { fg = "#c0caf5"; };
            hovered = { underline = true; };
          };
          
          which = {
            mask = { bg = "#1a1b26e6"; };
            cand = { fg = "#7dcfff"; };
            rest = { fg = "#565f89"; };
            desc = { fg = "#f7768e"; };
            separator = "  ";
            separator_style = { fg = "#565f89"; };
          };
          
          help = {
            on = { fg = "#f7768e"; };
            exec = { fg = "#7dcfff"; };
            desc = { fg = "#565f89"; };
            hovered = { bg = "#292e42"; bold = true; };
            footer = { fg = "#1a1b26"; bg = "#c0caf5"; };
          };
          
          filetype = {
            rules = [
              { mime = "image/*"; fg = "#7dcfff"; }
              { mime = "video/*"; fg = "#e0af68"; }
              { mime = "audio/*"; fg = "#e0af68"; }
              { mime = "application/zip"; fg = "#f7768e"; }
              { mime = "application/gzip"; fg = "#f7768e"; }
              { mime = "application/x-tar"; fg = "#f7768e"; }
              { mime = "application/x-bzip"; fg = "#f7768e"; }
              { mime = "application/x-bzip2"; fg = "#f7768e"; }
              { mime = "application/x-7z-compressed"; fg = "#f7768e"; }
              { mime = "application/x-rar"; fg = "#f7768e"; }
              { mime = "application/xz"; fg = "#f7768e"; }
              { name = "*/"; fg = "#7aa2f7"; }
              { name = ".*"; fg = "#565f89"; }
            ];
          };
        };
      };
    };
  };
}