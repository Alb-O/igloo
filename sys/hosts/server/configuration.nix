# NixOS-WSL Configuration
# WSL-specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
#
# This configuration provides:
# - Clean WSL environment without graphical components
# - Multi-user support via parameterized globals
# - Bootstrap-ready for first run
{
  lib,
  pkgs,
  user,
  host,
  ...
}:
{
  imports = [
    # Import our modular NixOS configuration
    ../../mod
  ];

  # WSL-specific configuration
  wsl.enable = true;
  wsl.defaultUser = user.username;
  wsl.startMenuLaunchers = true;

  # Enhanced WSL interoperability
  wsl.wslConf = {
    # Network configuration
    network = {
      generateHosts = true;
      generateResolvConf = true;
      hostname = host.hostname;
    };

    # Boot configuration
    boot = {
      systemd = true;
      command = ""; # Can add startup commands here
    };

    # Interoperability settings
    interop = {
      enabled = true;
      # Include Windows PATH but filter it intelligently
      appendWindowsPath = true;
    };

    # Automount settings for Windows drives
    automount = {
      enabled = true;
      root = "/mnt";
      # Remove metadata to fix Windows executable execution, allow execute for group
      options = "gid=100,umask=002,fmask=002,case=off,exec";
      mountFsTab = false; # Let systemd handle /etc/fstab
      ldconfig = false; # Use NixOS OpenGL instead
    };

    # User settings
    user.default = user.username;
  };

  # Generic admin user configuration
  users.users.admin = {
    isNormalUser = true;
    description = "System Administrator";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "systemd-journal"
    ];
    # Allow passwordless sudo for wheel group
    openssh.authorizedKeys.keys = [
      # Add SSH keys here if needed for remote access
    ];
  };

  # Enable passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  nix.settings = {
    experimental-features = lib.mkForce [ "nix-command" "flakes" ];
    max-jobs = lib.mkDefault 1;
    cores = lib.mkDefault 1;
    sandbox = false;
  };
  nix.channel.enable = lib.mkForce false;

  # Disable services that can cause issues on first boot
  services.openssh.enable = lib.mkForce false;
  services.keyd.enable = lib.mkForce false;

  # Ensure NetworkManager is available but not conflicting
  networking.networkmanager.enable = lib.mkDefault true;
  networking.useDHCP = lib.mkDefault true;

  # Disable graphical services that cause issues in WSL
  xdg.portal.enable = lib.mkForce false;
  security.rtkit.enable = lib.mkForce false;
  services.pipewire.enable = lib.mkForce false;

  # Essential system packages for WSL
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    htop
    tree
    # WSL-specific utilities
    wslu # WSL utilities for interop
  ];

  # Environment variables for WSL identification
  environment.variables = {
    WSL_DISTRO_NAME = "NixOS";
    IS_WSL = "true";
  };
}
