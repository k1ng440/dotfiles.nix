{
  perSystem =
    { pkgs, ... }:
    let
      drv =
        {
          lib,
          callPackage,
          stdenv,
          makeWrapper,
          czkawka,
          exiftool,
          pqiv,
          rsync,
          rclip,
          wlr-randr,
          extraPackages ? [ ],
        }:
        let
          wallpaper-go-unwrapped = callPackage ./_unwrapped.nix { };
        in
        stdenv.mkDerivation {
          pname = "wallpaper-go";
          inherit (wallpaper-go-unwrapped) version;

          preferLocalBuild = true;

          nativeBuildInputs = [
            makeWrapper
          ];

          buildCommand = /* sh */ ''
            makeWrapper "${wallpaper-go-unwrapped}/bin/wallpaper" "$out/bin/wallpaper" --prefix PATH : ${
              lib.makeBinPath (
                [
                  czkawka
                  exiftool
                  pqiv
                  rclip
                  rsync
                  wlr-randr
                ]
                ++ extraPackages
              )
            }
          '';

          passthru.unwrapped = wallpaper-go-unwrapped;

          inherit (wallpaper-go-unwrapped) meta;
        };
    in
    {
      packages.wallpaper-go = pkgs.callPackage drv { };
    };
}
