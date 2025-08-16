# Window rules for Niri
{
  window-rules = [
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
