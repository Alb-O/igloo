# Keyboard configuration - swap Esc and Caps Lock
{...}: {
  # Key remapping with keyd
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "esc";
            esc = "capslock";
          };
        };
      };
    };
  };
}
