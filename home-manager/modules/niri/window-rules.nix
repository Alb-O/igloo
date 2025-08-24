# Window rules for Niri
{
  window-rules = [
    # File picker - float and center
    {
      matches = [
        {
          app-id = "foot";
          title = "XDG File Picker";
        }
      ];
      default-column-width = { proportion = 0.65; };
      default-window-height = { proportion = 0.8; };
      open-floating = true;
    }
    # WezTerm workaround
    {
      matches = [{app-id = "^org\\.wezfurlong\\.wezterm$";}];
      default-column-width = {};
    }

    # Firefox picture-in-picture
    {
      matches = [
        {
          app-id = "firefox$";
          title = "^Picture-in-Picture$";
        }
      ];
      open-floating = true;
    }
  ];
}
