{
  lib,
  fetchzip,
  autoPatchelfHook,
  unzip,
  zlib,
  openssl,
  stdenv,
}:

let
  version = "0.5.8";

  # Map platform to release asset URL and hash.
  # Note: Replace lib.fakeSha256 with the real hash after first build.
  srcInfo =
    rec {
      x86_64-linux = {
        url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-linux-x64.zip";
        hash = "sha256-ESi9SJWUwwBCZGDSsS5+od9Fc75BgSRtqWc0CckTavg=";
      };
      aarch64-linux = {
        url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-linux-arm64.zip";
        hash = lib.fakeSha256;
      };
      x86_64-darwin = {
        url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-darwin-x64.zip";
        hash = lib.fakeSha256;
      };
      aarch64-darwin = {
        url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
        hash = lib.fakeSha256;
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "opencode-bin";
  inherit version;

  src = fetchzip {
    url = srcInfo.url;
    # Typed SRI placeholder; Nix will print the real hash to paste
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    stripRoot = false;
  };

  nativeBuildInputs = [ unzip ] ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  # Libraries typically needed by bun-compiled binaries
  buildInputs =
    [ ]
    ++ lib.optionals stdenv.isLinux [
      zlib
      openssl
      stdenv.cc.cc.lib
    ];

  installPhase = ''
        runHook preInstall

        # Install all release files to a dedicated dir to preserve any assets
        mkdir -p "$out/lib/opencode"
        cp -R . "$out/lib/opencode"

        # Create a wrapper that runs from that directory to satisfy any relative paths
        mkdir -p "$out/bin"
        cat > "$out/bin/opencode" <<'SH'
    #!/usr/bin/env bash
    set -euo pipefail
    cd "$(dirname "''${BASH_SOURCE[0]}")/../lib/opencode"
    # Ensure libstdc++ is available on NixOS if needed (bun sometimes dlopens it)
    if [ "$(uname)" = Linux ]; then
      export LD_LIBRARY_PATH="${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}:"''${LD_LIBRARY_PATH-}
    fi
    exec ./opencode "$@"
    SH
        chmod +x "$out/bin/opencode"

        runHook postInstall
  '';

  meta = with lib; {
    description = "OpenCode prebuilt binary wrapped for Nix";
    homepage = "https://github.com/sst/opencode";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "opencode";
  };
})
