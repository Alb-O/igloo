# System-wide packages configuration
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Essential tools
    wget
    just
    firefox
    foot
    helix
    # Display manager
    sddm-astronaut
  ];
}
