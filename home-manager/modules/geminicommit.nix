# Geminicommit configuration
{
  pkgs,
  lib,
  globals,
  ...
}: {
  home.packages = [pkgs.geminicommit];

  home.activation.geminicommit = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [[ -n "${globals.env.GEMINI_API_KEY or ""}" ]]; then
          config_dir="$HOME/.config/geminicommit"
          config_file="$config_dir/config.toml"

          # Create config directory if it doesn't exist
          mkdir -p "$config_dir"

          # Create or update config file with API key
          cat > "$config_file" << EOF
    api_key = "${globals.env.GEMINI_API_KEY}"
    EOF

          echo "Geminicommit configured with API key"
        else
          echo "Warning: GEMINI_API_KEY not found in environment"
        fi
  '';
}
