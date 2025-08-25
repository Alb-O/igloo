{pkgs}: let
  setupScript = pkgs.writeShellScriptBin "setup-background-terminals" ''
    set -euo pipefail

    # Script to set up background terminals on all monitors

    # Get all monitor connector names from niri
    MONITORS=$(${pkgs.niri}/bin/niri msg outputs | grep "Output " | sed 's/.*(\(.*\))/\1/')

    if [ -z "$MONITORS" ]; then
        echo "No monitors found, exiting..."
        exit 1
    fi

    echo "Found monitors: $MONITORS"

    # For each monitor, create a background terminal using windowtolayer
    for MONITOR in $MONITORS; do
        echo "Setting up background terminal on monitor: $MONITOR"

        # Use windowtolayer to spawn foot terminal directly on the specified monitor
        ${pkgs.windowtolayer}/bin/windowtolayer -m -l bottom -i all --output-name="$MONITOR" ${pkgs.foot}/bin/foot -e "tmux" &
    done
    wait
    echo "Background terminal setup complete"
  '';
in
  setupScript
