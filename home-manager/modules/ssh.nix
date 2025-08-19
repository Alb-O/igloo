{globals, ...}: {
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
    # Add any SSH-related environment variables from environment here
    # Example: SSH_KEY_PATH = builtins.getEnv "SSH_KEY_PATH";
  };
}
