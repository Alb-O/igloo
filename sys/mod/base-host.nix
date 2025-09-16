{ lib, pkgs, user, host, ... }:
let
  localeKeys = [
    "LC_ADDRESS"
    "LC_IDENTIFICATION"
    "LC_MEASUREMENT"
    "LC_MONETARY"
    "LC_NAME"
    "LC_NUMERIC"
    "LC_PAPER"
    "LC_TELEPHONE"
    "LC_TIME"
  ];
  activeLocale = host.locale or "en_US.UTF-8";
  supportedLocales = lib.unique ([
    "${activeLocale}/UTF-8"
    "en_US.UTF-8/UTF-8"
    "C.UTF-8/UTF-8"
  ] ++ (host.extraLocales or []));
  extraLocaleSettings = lib.genAttrs localeKeys (_: activeLocale);
  userExtraGroups = lib.unique ([ "wheel" ] ++ (host.extraGroups or []));
in
{
  networking.hostName = host.hostname;
  time.timeZone = host.timeZone;

  i18n = {
    defaultLocale = activeLocale;
    supportedLocales = supportedLocales;
    extraLocaleSettings = extraLocaleSettings;
  };

  users.users.${user.username} = {
    isNormalUser = true;
    description = user.name;
    home = user.homeDirectory;
    extraGroups = userExtraGroups;
  };

  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  system.stateVersion = host.stateVersion;
  nixpkgs.hostPlatform = host.architecture;
}
