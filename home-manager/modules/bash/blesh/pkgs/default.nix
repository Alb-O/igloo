{
  lib,
  stdenv,
}: let
  version = "local";
in
  stdenv.mkDerivation {
    pname = "blesh-contrib";
    inherit version;

    src = ../contrib;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/blesh-contrib
      cp -r * $out/share/blesh-contrib/

      runHook postInstall
    '';

    meta = with lib; {
      description = "A collection of extensions for ble.sh";
      homepage = "https://github.com/akinomyoga/blesh-contrib";
      license = licenses.bsd3;
      platforms = platforms.all;
      maintainers = [];
    };
  }
