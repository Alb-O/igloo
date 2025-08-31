{pkgs}: let
  setupScript = pkgs.writeShellScriptBin "setup-background-terminals" ''
    set -euo pipefail

    # Script to set up background terminals on all monitors using kitty panel

    # Get all monitor connector names from niri
    MONITORS=$(${pkgs.niri}/bin/niri msg outputs | grep "Output " | sed 's/.*(\(.*\))/\1/')

    if [ -z "$MONITORS" ]; then
        echo "No monitors found, exiting..."
        exit 1
    fi

    # For each monitor, create a background terminal using kitten panel
    for MONITOR in $MONITORS; do
        # Use kitten panel to spawn background terminal
        ${pkgs.kitty}/bin/kitten panel --output-name $MONITOR --focus-policy exclusive --detach=yes --edge=background
    done
    wait
  '';
in
  setupScript
