# Miscellaneous settings for Niri
{
  # Startup programs
  spawn-at-startup = [
    {command = ["waybar"];}
    {command = ["setup-background-terminals"];}
  ];

  # Client-side decorations preference
  prefer-no-csd = true;

  overview = {
    backdrop-color = "#1A1B26";
  };

  # Screenshot settings
  screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

  # Animation settings
  animations = {
    # off = true;
    # slowdown = 3.0;
  };
}
