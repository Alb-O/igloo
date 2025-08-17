# Desktop environment configuration
# Handles themes, fonts, and desktop-wide settings
{pkgs, ...}: let
  fonts = import ../lib/fonts.nix pkgs;
  #colors = import ../lib/themes/default.nix;
  # Generate GTK CSS from theme colors
  # gtkCss = ''
  #   /* Primary colors */
  #   @define-color accent_color ${colors.ui.interactive.primary};
  #   @define-color accent_bg_color ${colors.ui.interactive.primary};
  #   @define-color accent_fg_color ${colors.ui.foreground.primary};
  #
  #   /* Background colors */
  #   @define-color window_bg_color ${colors.ui.background.primary};
  #   @define-color window_fg_color ${colors.ui.foreground.primary};
  #   @define-color view_bg_color ${colors.ui.background.secondary};
  #   @define-color view_fg_color ${colors.ui.foreground.primary};
  #   @define-color headerbar_bg_color ${colors.ui.background.secondary};
  #   @define-color headerbar_fg_color ${colors.ui.foreground.primary};
  #   @define-color headerbar_border_color ${colors.ui.border.primary};
  #   @define-color headerbar_backdrop_color ${colors.ui.background.tertiary};
  #   @define-color headerbar_shade_color ${colors.ui.background.tertiary};
  #   @define-color card_bg_color ${colors.ui.background.secondary};
  #   @define-color card_fg_color ${colors.ui.foreground.primary};
  #   @define-color card_shade_color ${colors.ui.background.tertiary};
  #   @define-color dialog_bg_color ${colors.ui.background.primary};
  #   @define-color dialog_fg_color ${colors.ui.foreground.primary};
  #   @define-color popover_bg_color ${colors.ui.background.secondary};
  #   @define-color popover_fg_color ${colors.ui.foreground.primary};
  #   @define-color shade_color ${colors.ui.background.tertiary};
  #   @define-color scrollbar_outline_color ${colors.ui.border.primary};
  #
  #   /* Interactive elements */
  #   @define-color blue_1 ${colors.ui.interactive.secondary};
  #   @define-color blue_2 ${colors.ui.interactive.secondary};
  #   @define-color blue_3 ${colors.ui.interactive.secondary};
  #   @define-color blue_4 ${colors.ui.interactive.secondary};
  #   @define-color blue_5 ${colors.ui.interactive.secondary};
  #   @define-color green_1 ${colors.ui.status.success};
  #   @define-color green_2 ${colors.ui.status.success};
  #   @define-color green_3 ${colors.ui.status.success};
  #   @define-color green_4 ${colors.ui.status.success};
  #   @define-color green_5 ${colors.ui.status.success};
  #   @define-color yellow_1 ${colors.ui.status.warning};
  #   @define-color yellow_2 ${colors.ui.status.warning};
  #   @define-color yellow_3 ${colors.ui.status.warning};
  #   @define-color yellow_4 ${colors.ui.status.warning};
  #   @define-color yellow_5 ${colors.ui.status.warning};
  #   @define-color orange_1 ${colors.ui.interactive.accent};
  #   @define-color orange_2 ${colors.ui.interactive.accent};
  #   @define-color orange_3 ${colors.ui.interactive.accent};
  #   @define-color orange_4 ${colors.ui.interactive.accent};
  #   @define-color orange_5 ${colors.ui.interactive.accent};
  #   @define-color red_1 ${colors.ui.status.error};
  #   @define-color red_2 ${colors.ui.status.error};
  #   @define-color red_3 ${colors.ui.status.error};
  #   @define-color red_4 ${colors.ui.status.error};
  #   @define-color red_5 ${colors.ui.status.error};
  #   @define-color purple_1 ${colors.ui.interactive.primary};
  #   @define-color purple_2 ${colors.ui.interactive.primary};
  #   @define-color purple_3 ${colors.ui.interactive.primary};
  #   @define-color purple_4 ${colors.ui.interactive.primary};
  #   @define-color purple_5 ${colors.ui.interactive.primary};
  #
  #   /* Special states */
  #   @define-color success_color ${colors.ui.status.success};
  #   @define-color success_bg_color ${colors.ui.status.success};
  #   @define-color success_fg_color ${colors.ui.foreground.primary};
  #   @define-color warning_color ${colors.ui.status.warning};
  #   @define-color warning_bg_color ${colors.ui.status.warning};
  #   @define-color warning_fg_color ${colors.ui.foreground.primary};
  #   @define-color error_color ${colors.ui.status.error};
  #   @define-color error_bg_color ${colors.ui.status.error};
  #   @define-color error_fg_color ${colors.ui.foreground.primary};
  #   @define-color destructive_color ${colors.ui.status.error};
  #   @define-color destructive_bg_color ${colors.ui.status.error};
  #   @define-color destructive_fg_color ${colors.ui.foreground.primary};
  #
  #   /* Selection and focus */
  #   @define-color borders ${colors.ui.border.primary};
  #   @define-color theme_unfocused_borders ${colors.ui.border.secondary};
  #   @define-color theme_unfocused_selected_bg_color ${colors.ui.special.selection};
  #   @define-color theme_selected_bg_color ${colors.ui.special.selection};
  #   @define-color theme_selected_fg_color ${colors.ui.foreground.primary};
  #   @define-color insensitive_bg_color ${colors.ui.background.tertiary};
  #   @define-color insensitive_fg_color ${colors.ui.foreground.tertiary};
  #   @define-color insensitive_borders ${colors.ui.border.secondary};
  #
  #   /* Additional semantic mappings */
  #   @define-color sidebar_bg_color ${colors.ui.background.secondary};
  #   @define-color sidebar_fg_color ${colors.ui.foreground.primary};
  #   @define-color sidebar_backdrop_color ${colors.ui.background.tertiary};
  #   @define-color sidebar_shade_color ${colors.ui.background.tertiary};
  #   @define-color secondary_sidebar_bg_color ${colors.ui.background.tertiary};
  #   @define-color secondary_sidebar_fg_color ${colors.ui.foreground.secondary};
  #   @define-color secondary_sidebar_backdrop_color ${colors.ui.background.tertiary};
  #   @define-color secondary_sidebar_shade_color ${colors.ui.background.tertiary};
  # '';
in {
  # Fontconfig for better font rendering
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        fonts.sansSerif.name
        "DejaVu Sans"
      ];
      serif = [
        fonts.serif.name
        "DejaVu Serif"
      ];
      monospace = [
        fonts.mono.name
        "DejaVu Sans Mono"
      ];
    };
  };

  # Dark theme preferences with UI scaling
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      # GTK UI scaling - 1.25 = 125% scale
      text-scaling-factor = 1.25;
    };
  };

  # GTK theme configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.libadwaita;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    font = {
      name = fonts.sansSerif.name;
      size = fonts.sansSerif.size.small;
      package = fonts.sansSerif.package;
    };

    # GTK bookmarks file
    gtk3.bookmarks = [];

    # Enable GTK4 features
    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
      gtk-xft-rgba = "rgb";
      gtk-xft-dpi = 96;
    };

    gtk4.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
      gtk-xft-rgba = "rgb";
      gtk-xft-dpi = 96;
    };

    # Apply custom theme colors via CSS
    #gtk3.extraCss = gtkCss;
    #gtk4.extraCss = gtkCss;
  };
}
