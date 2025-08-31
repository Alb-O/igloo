# Input device configuration for Niri
{
  input = {
    keyboard = {
      xkb = {
        # Layout and options can be configured here
        # layout = "us,ru";
        # options = "grp:win_space_toggle,compose:ralt,ctrl:nocaps";
      };
      repeat-rate = 35;
      repeat-delay = 200;
      numlock = true;
    };

    touchpad = {
      tap = true;
      natural-scroll = true;
      # accel-speed = 0.2;
      # accel-profile = "flat";
    };

    mouse = {
      # natural-scroll = false;
      # accel-speed = 0.2;
    };

    trackpoint = {
      # natural-scroll = false;
      # accel-speed = 0.2;
    };

    focus-follows-mouse = {
      enable = true;
      max-scroll-amount = "50%";
    };
    workspace-auto-back-and-forth = true;
  };
}
