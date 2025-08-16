# NixOS system configuration
{
  pkgs,
  globals,
  ...
}: {
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

  # Set your time zone.
  time.timeZone = globals.env.TIMEZONE or "UTC";

  # Select internationalisation properties.
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

  # Configure console keymap
  console.keyMap = "us";

  # No sudo password for wheel users
  security.sudo.wheelNeedsPassword = false;

  # Set your system hostname
  networking.hostName = globals.system.hostname;

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    ${globals.user.username} = {
      isNormalUser = true;
      description = globals.user.name;
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

  # Host-specific SDDM theme override
  services.displayManager.sddm = {
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs; [sddm-astronaut];
    theme = "sddm-astronaut-theme";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = globals.system.stateVersion;

  # Platform configuration
  nixpkgs.hostPlatform = globals.system.architecture;
}
