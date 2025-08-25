#!/usr/bin/env bash
# Find the root directory of a Nix flake
# This script traverses up the directory tree looking for flake.nix

find_flake_root() {
    local current_dir="$(pwd)"
    
    # Traverse up the directory tree
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/flake.nix" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    # Not found
    return 1
}

# If called directly (not sourced), print the result
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if flake_root=$(find_flake_root); then
        echo "$flake_root"
        exit 0
    else
        echo "Error: No flake.nix found in current directory or parent directories" >&2
        exit 1
    fi
fi

# If sourced, export the function and set FLAKE_ROOT if not already set
if [ -z "${FLAKE_ROOT:-}" ]; then
    if flake_root=$(find_flake_root 2>/dev/null); then
        export FLAKE_ROOT="$flake_root"
    fi
fi