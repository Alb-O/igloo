# Firefox extensions configuration
# Managed extensions and their installation settings
{ ... }:
{
  extensionSettings = {
    "addon@darkreader.org" = {
      # Dark Reader
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
      installation_mode = "force_installed";
    };
    "uBlock0@raymondhill.net" = {
      # uBlock Origin
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      installation_mode = "force_installed";
    };
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
      # BitWarden
      # Correct slug is bitwarden-password-manager and pattern is /downloads/latest/<slug>/latest.xpi
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
      installation_mode = "force_installed";
    };
    "sponsorBlocker@ajay.app" = {
      # SponsorBlock
      # Remove erroneous /file/ segment
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
      installation_mode = "force_installed";
    };
    "clipper@obsidian.md" = {
      # Obsidian Clipper
      # Correct slug is obsidian-web-clipper
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/obsidian-web-clipper/latest.xpi";
      installation_mode = "force_installed";
    };
  };
}
