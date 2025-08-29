# NixOS system configuration
{ pkgs, user, host, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./hardware-extra.nix
    ./graphics.nix
    ../../modules
  ];

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = ["ntfs"];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = host.timeZone;

  # Locale
  i18n.defaultLocale = host.locale;

  # Generate all locales needed
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "en_AU.UTF-8/UTF-8"
    "C.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = host.locale;
    LC_IDENTIFICATION = host.locale;
    LC_MEASUREMENT = host.locale;
    LC_MONETARY = host.locale;
    LC_NAME = host.locale;
    LC_NUMERIC = host.locale;
    LC_PAPER = host.locale;
    LC_TELEPHONE = host.locale;
    LC_TIME = host.locale;
  };

  # Configure console keymap
  console.keyMap = "us";

  # No sudo password for wheel users
  security.sudo.wheelNeedsPassword = false;

  # Set your system hostname
  networking.hostName = host.hostname;

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    ${user.username} = {
      isNormalUser = true;
      description = user.name;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "docker"
      ];
    };
  };

  # Display manager configuration
  services.displayManager.sddm = {
    package = pkgs.kdePackages.sddm;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = host.stateVersion;

  # Platform configuration
  nixpkgs.hostPlatform = host.architecture;
}
