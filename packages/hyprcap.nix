{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  hyprland,
  wf-recorder,
  jq,
  grim,
  slurp,
  wl-clipboard,
  libnotify,
  withFreeze ? true,
  hyprpicker,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hyprcap";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "alonso-herreros";
    repo = "hyprcap";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qTlv4hRy9CvB+ZkNxXuxtLjDHsjiyjjooUlDFxwqQOc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    set -x
    ls -F
    runHook preInstall

    install -Dm755 hyprcap -t "$out/bin"
    wrapProgram "$out/bin/hyprcap" \
      --prefix PATH ":" ${
        lib.makeBinPath (
          [
            hyprland
            wf-recorder
            grim
            slurp
            jq
            wl-clipboard
            libnotify
          ]
          ++ lib.optionals withFreeze [ hyprpicker ]
        )
      }

    runHook postInstall
  '';

  meta = {
    inherit (hyprland.meta) platforms;
    homepage = "https://github.com/alonso-herreros/hyprcap";
    description = "Utility to easily capture screenshots and screen recordings on Hyprland.";
    license = lib.licenses.gpl3Only;
    mainProgram = "hyprcap";
  };
})
