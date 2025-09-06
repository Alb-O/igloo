# GNOME Keyring configuration without desktop dependencies
{ pkgs, ... }:
{
  # GNOME Keyring service - minimal keyring without GNOME desktop
  services.gnome.gnome-keyring.enable = true;

  # PAM integration for automatic keyring unlock
  security.pam.services = {
    login.enableGnomeKeyring = true;
  };

  # Required packages for keyring functionality
  environment.systemPackages = with pkgs; [
    gnome-keyring
    libsecret # For secret storage API
  ];
}
