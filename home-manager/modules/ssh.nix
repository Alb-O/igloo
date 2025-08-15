{ globals, ... }:
{
  programs.ssh = {
    enable = true;
    # Basic SSH configuration without external identity agent
    extraConfig = ''
      Host *
          AddKeysToAgent yes
    '';
  };

  # Set environment variables for SSH
  home.sessionVariables = {
    # Add any SSH-related environment variables from .env here
    # Example: SSH_KEY_PATH = globals.env.SSH_KEY_PATH or "";
  };
}
