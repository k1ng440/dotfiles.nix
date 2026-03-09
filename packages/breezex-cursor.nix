{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation {
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

  installPhase = ''
    install -dm 755 $out/share/icons
    cp -dr --no-preserve=ownership BreezeX-Dark $out/share/icons/
    cp -dr --no-preserve=ownership BreezeX-Light $out/share/icons/
  '';

  meta = with lib; {
    description = "BreezeX Cursor Theme";
    homepage = "https://github.com/ful1e5/BreezeX_Cursor";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
