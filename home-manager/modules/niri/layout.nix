# Layout settings for Niri
{ colors }:
{
  layout = {
    gaps = 16;
    center-focused-column = "never";

    preset-column-widths = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];

    default-column-width = {
      proportion = 0.5;
    };

    focus-ring = {
      width = 2;
      active.color = colors.ui.interactive.primary;
      inactive.color = colors.ui.foreground.secondary;
    };

    border = {
      enable = false;
      width = 4;
      active.color = colors.ui.interactive.accent;
      inactive.color = colors.ui.border.primary;
      urgent.color = colors.ui.status.error;
    };

    shadow = {
      # Enable shadows if desired
      # on = true;
      # softness = 30;
      # spread = 5;
      # offset = { x = 0; y = 5; };
      # color = "#0007";
    };
  };
}
