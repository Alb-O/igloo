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
  globals,
  ...
}: {
  imports = [
    # Import our modular NixOS configuration
    ../../modules
  ];

  # WSL-specific configuration
  wsl.enable = true;
  wsl.defaultUser = "admin";
  wsl.startMenuLaunchers = true;

  # Disable Windows PATH integration for cleaner environment
  wsl.wslConf.interop.appendWindowsPath = false;

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

  # System configuration
  system.stateVersion = globals.system.stateVersion;
  networking.hostName = globals.system.hostname;

  # Time zone and locale
  time.timeZone = globals.env.TIMEZONE or "UTC";
  i18n.defaultLocale = globals.env.DEFAULT_LOCALE or "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = globals.env.LC_LOCALE or "en_US.UTF-8";
    LC_IDENTIFICATION = globals.env.LC_LOCALE or "en_US.UTF-8";
    LC_MEASUREMENT = globals.env.LC_LOCALE or "en_US.UTF-8";
    LC_MONETARY = globals.env.LC_LOCALE or "en_US.UTF-8";
    LC_NAME = globals.env.LC_LOCALE or "en_US.UTF-8";
    LC_NUMERIC = globals.env.LC_LOCALE or "en_US.UTF-8";
    LC_PAPER = globals.env.LC_LOCALE or "en_US.UTF-8";
    LC_TELEPHONE = globals.env.LC_LOCALE or "en_US.UTF-8";
    LC_TIME = globals.env.LC_LOCALE or "en_US.UTF-8";
  };

  # Platform configuration
  nixpkgs.hostPlatform = globals.system.architecture;

  # Enable experimental features (using mkForce to override module conflicts)
  nix.settings.experimental-features = lib.mkForce [
    "nix-command"
    "flakes"
  ];

  # Disable legacy channels that cause storePath errors
  nix.channel.enable = lib.mkForce false;

  # Disable display managers and graphical services for WSL
  services.displayManager.autoLogin.enable = lib.mkForce false;
  programs.niri.enable = lib.mkForce false;

  # Optimize build settings for WSL
  nix.settings = {
    max-jobs = lib.mkDefault 1;
    cores = lib.mkDefault 1;
    sandbox = false;
  };

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
  ];
}
