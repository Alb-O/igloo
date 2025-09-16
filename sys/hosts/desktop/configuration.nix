# NixOS system configuration
{
  pkgs,
  user,
  host,
  inputs,
  fonts,
  ...
}:
let
  niri = inputs.kakkle.packages.x86_64-linux.niri;
in
{
  imports = [
    ./hardware-configuration.nix
    ./hardware-extra.nix
    ./nouveau.nix
    #./nvidia.nix
    ../../mod
  ];

  environment.systemPackages = with pkgs; [
    niri
    lm_sensors
    inxi
    lshw
    pciutils
    virtualglLib
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = false;
    limine.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.supportedFilesystems = [ "ntfs" ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Disable USB autosuspend to prevent mouse detection issues
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  services.displayManager = {
    enable = true;
    sessionPackages = [ niri ];
    # lemurs = {
    #   enable = true;
    #   settings = {
    #     background.show_background = true;
    #   };
    # };
    ly = {
      enable = true;
      settings = {
        animation = "matrix";
      };
    };
  };

  # services.displayManager.defaultSession = "";
  # services.displayManager.gdm.enable = true;
  # services.displayManager.gdm.wayland = true;

  services.kmscon = {
    enable = true;
    fonts = [
      {
        name = fonts.mono.name;
        package = fonts.mono.package;
      }
    ];
    extraConfig = "font-size=${toString fonts.mono.size.large}";
  };

  # Required for GNOME portal GSettings access
  programs.dconf.enable = true;

  # udev packages for desktop integration
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  # Environment variables for desktop
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Time zone
  console.keyMap = "us";
}
