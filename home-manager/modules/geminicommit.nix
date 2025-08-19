# Geminicommit configuration
{
  pkgs,
  lib,
  ...
}: let
  geminiApiKey = builtins.getEnv "GEMINI_API_KEY";
in {
  home.packages = [pkgs.geminicommit];

  home.activation.geminicommit = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [[ -n "${geminiApiKey}" ]]; then
          config_dir="$HOME/.config/geminicommit"
          config_file="$config_dir/config.toml"

          # Create config directory if it doesn't exist
          mkdir -p "$config_dir"

          # Create or update config file with API key
          cat > "$config_file" << EOF
    api_key = "${geminiApiKey}"
    EOF

          echo "Geminicommit configured with API key"
        else
          echo "Warning: GEMINI_API_KEY not found in environment"
        fi
  '';
}
