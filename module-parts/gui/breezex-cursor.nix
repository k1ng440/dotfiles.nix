_: {
  perSystem =
    { pkgs, ... }:
    let
      drv =
        { fetchurl, stdenvNoCC }:
        stdenvNoCC.mkDerivation {
          pname = "breezex-cursor";
          version = "2.0.1";
          srcs = [
            (fetchurl {
              url = "https://github.com/ful1e5/BreezeX_Cursor/releases/download/v2.0.1/BreezeX-Dark.tar.xz";
              hash = "sha256-jN90NGaw8VZf5fKQ3UjvTALZF3hFjQ08xWQ3UVJVtlM=";
            })
            (fetchurl {
              url = "https://github.com/ful1e5/BreezeX_Cursor/releases/download/v2.0.1/BreezeX-Light.tar.xz";
              hash = "sha256-QMG9siTmEeA8mGWkmltPgTGXTLb6swr0KMKhqWlISqg=";
            })
          ];

          sourceRoot = ".";
          installPhase = /* sh */ ''
            install -dm 755 $out/share/icons
            cp -dr --no-preserve=ownership BreezeX-Dark $out/share/icons/
            cp -dr --no-preserve=ownership BreezeX-Light $out/share/icons/
          '';
        };
    in
    {
      packages.breezex-cursor = pkgs.callPackage drv { };
    };

  flake.modules.nixos.wm =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: _prev: {
          inherit (pkgs.custom) breezex-cursor;
        })
      ];
      environment.systemPackages = [ pkgs.custom.breezex-cursor ];

      custom.gtk.cursor = {
        package = pkgs.custom.breezex-cursor;
        name = "BreezeX-Dark";
      };
    };
}
