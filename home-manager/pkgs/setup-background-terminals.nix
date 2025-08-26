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

    echo "Found monitors: $MONITORS"

    # For each monitor, create a background terminal using kitten panel
    for MONITOR in $MONITORS; do
        echo "Setting up background terminal on monitor: $MONITOR"

        # Use kitten panel to spawn background terminal with tmux
        WAYLAND_DISPLAY="$WAYLAND_DISPLAY" ${pkgs.kitty}/bin/kitten panel --edge=background ${pkgs.tmux}/bin/tmux &
    done
    wait
    echo "Background terminal setup complete"
  '';
in
  setupScript
