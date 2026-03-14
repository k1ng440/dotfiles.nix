{
  version ? "git",
  extraPackages ? [ ],
  runtimeDeps ? [
    brightnessctl
    cava
    cliphist
    ddcutil
    wlsunset
    wl-clipboard
    wlr-randr
    imagemagick
    wget
    (python3.withPackages (pp: lib.optional calendarSupport pp.pygobject3))
  ],

  lib,
  stdenvNoCC,
  fetchFromGitHub,
  # build
  qt6,
  quickshell,
  # runtime deps
  brightnessctl,
  cava,
  cliphist,
  ddcutil,
  wlsunset,
  wl-clipboard,
  wlr-randr,
  imagemagick,
  wget,
  python3,
  wayland-scanner,
  # calendar support
  calendarSupport ? false,
  evolution-data-server,
  libical,
  glib,
  libsoup_3,
  json-glib,
  gobject-introspection,
}:
let
  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia-shell";
    rev = "main";
    hash = "sha256-YnSRPOQC+fwSE3aA2C1rt9zaI4i3S4LTYY/3fqmRM4s=";
  };

  giTypelibPath = lib.makeSearchPath "lib/girepository-1.0" [
    evolution-data-server
    libical
    glib.out
    libsoup_3
    json-glib
    gobject-introspection
  ];
in
stdenvNoCC.mkDerivation {
  pname = "noctalia-shell";
  inherit version src;

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtmultimedia
  ];

  installPhase = ''
    mkdir -p $out/share/noctalia-shell $out/bin
    cp -r . $out/share/noctalia-shell
    ln -s ${quickshell}/bin/qs $out/bin/noctalia-shell
  '';

  preFixup = ''
    qtWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath (runtimeDeps ++ extraPackages)}
      --prefix XDG_DATA_DIRS : ${wayland-scanner}/share
      --add-flags "-p $out/share/noctalia-shell"
      ${lib.optionalString calendarSupport "--prefix GI_TYPELIB_PATH : ${giTypelibPath}"}
    )
  '';

  meta = {
    description = "A sleek and minimal desktop shell thoughtfully crafted for Wayland, built with Quickshell.";
    homepage = "https://github.com/noctalia-dev/noctalia-shell";
    license = lib.licenses.mit;
    mainProgram = "noctalia-shell";
  };
}
