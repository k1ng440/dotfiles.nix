_: {
  perSystem =
    { pkgs, ... }:
    let
      # terminal (control) release, shipped under the desktop app's tag
      drv =
        {
          lib,
          stdenv,
          fetchurl,
          makeWrapper,
          zlib,
          libxcrypt,
        }:
        let
          version = "0.1.53";
          pname = "strata";
        in
        stdenv.mkDerivation {
          inherit pname version;

          src = fetchurl {
            url = "https://github.com/Niko1221/Strata/releases/download/v0.2.7/strata-control-${version}-linux-x86_64.tar.gz";
            hash = "sha256:6f746e48d3abfd2c660fe460336ece5c66caf75610771f819e279de6e7adfe65";
          };

          # archive unpacks flat (bin/, python/, strata.py, …)
          sourceRoot = ".";

          nativeBuildInputs = [ makeWrapper ];

          # private python runtime ships most native libs; these come from the host
          installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp -a . $out/

            wrapProgram $out/bin/strata \
              --prefix LD_LIBRARY_PATH : ${
                lib.makeLibraryPath [
                  zlib
                  stdenv.cc.cc.lib
                  libxcrypt
                ]
              }

            runHook postInstall
          '';

          meta = {
            description = "Local AI terminal: chat, code and serve models from the GPU";
            homepage = "https://github.com/Niko1221/Strata";
            license = lib.licenses.mit;
            platforms = [ "x86_64-linux" ];
            mainProgram = "strata";
          };
        };
    in
    {
      packages.strata = pkgs.callPackage drv { };
    };

  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: _prev: {
          inherit (pkgs.custom) strata;
        })
      ];

      environment.systemPackages = [
        pkgs.strata # overlay-ed above
      ];
    };
}
