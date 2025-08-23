# Layout settings for Niri
{}: {
  layout = {
    gaps = 16;
    center-focused-column = "never";

    preset-column-widths = [
      {proportion = 0.33333;}
      {proportion = 0.5;}
      {proportion = 0.66667;}
    ];

    default-column-width = {
      proportion = 0.5;
    };

    focus-ring = {
      width = 2;
      active.color = "#ffffff";
      inactive.color = "#888888";
    };

    border = {
      enable = false;
      width = 4;
      active.color = "#ffffff";
      inactive.color = "#444444";
      urgent.color = "#ff0000";
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
