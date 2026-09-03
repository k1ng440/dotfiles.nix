_: {
  perSystem =
    { pkgs, ... }:
    let
      drv =
        {
          appimageTools,
          fetchurl,
          makeWrapper,
        }:
        let
          pname = "claude-desktop";
          version = "1.9255.2-2.0.16";
          src = fetchurl {
            url = "https://github.com/aaddrick/claude-desktop-debian/releases/download/v2.0.16%2Bclaude1.9255.2/claude-desktop-${version}-amd64.AppImage";
            hash = "sha256-4EUjXNKnGe4v/HMUEQinAUcUGX4hINyuKBPmfwmjSlk=";
          };
          appimageContents = appimageTools.extract { inherit pname version src; };
        in
        appimageTools.wrapType2 {
          inherit pname version src;
          nativeBuildInputs = [ makeWrapper ];
          extraInstallCommands = /* sh */ ''
            wrapProgram $out/bin/${pname} \
              --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

            install -m 444 -D \
              ${appimageContents}/usr/share/applications/io.github.aaddrick.claude-desktop-debian.desktop \
              $out/share/applications/claude-desktop.desktop
            substituteInPlace $out/share/applications/claude-desktop.desktop \
              --replace-fail 'Exec=AppRun' 'Exec=${pname}'
            cp -r ${appimageContents}/usr/share/icons $out/share
          '';

          meta = {
            description = "Claude AI desktop application";
            homepage = "https://claude.ai";
            platforms = [ "x86_64-linux" ];
          };
        };
    in
    {
      packages.claude-desktop = pkgs.callPackage drv { };
    };

  flake.modules.nixos.programs_claude-desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.custom.claude-desktop
      ];

      xdg.mime.defaultApplications = {
        "x-scheme-handler/claude" = "claude-desktop.desktop";
      };

      custom = {
        programs.niri.settings.window-rules = [
          {
            matches = [ { app-id = "^Claude$"; } ];
            open-maximized = true;
          }
        ];

        persist.home.directories = [
          ".config/Claude"
        ];
      };
    };
}
