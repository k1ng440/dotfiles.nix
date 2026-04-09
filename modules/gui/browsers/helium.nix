{ lib, self, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      drv =
        {
          sources,
          appimageTools,
          makeWrapper,
        }:
        let
          pname = "helium";
          source = sources.helium;
          appimageContents = appimageTools.extract source;
        in
        appimageTools.wrapType2 (
          source
          // {
            nativeBuildInputs = [ makeWrapper ];
            extraInstallCommands = /* sh */ ''
              wrapProgram $out/bin/${pname} \
              --set-default XDG_DATA_HOME "$HOME/.local/share" \
              --set-default TZ "Asia/Dhaka" \
              --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

              install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
              substituteInPlace $out/share/applications/${pname}.desktop \
              --replace 'Exec=AppRun' 'Exec=${pname}'
              cp -r ${appimageContents}/usr/share/icons $out/share
            '';

            # Pass through files from the root fs
            extraBwrapArgs = [
              "--ro-bind-try /etc/chromium/policies/managed/default.json /etc/chromium/policies/managed/default.json"
              "--ro-bind-try /etc/xdg/ /etc/xdg/"
            ];

            meta = {
              description = "Private, fast, and honest web browser";
              homepage = "https://helium.computer/";
              platforms = [
                "x86_64-linux"
                "aarch64-linux"
              ];
            };
          }
        );
    in
    {
      packages.helium = pkgs.callPackage drv {
        sources = self.libCustom.nvFetcherSources pkgs;
      };
    };

  flake.modules.nixos.gui =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: _prev: {
          inherit (pkgs.custom) helium;
        })
      ];

      environment = {
        sessionVariables = {
          DEFAULT_BROWSER = lib.getExe pkgs.helium;
          BROWSER = lib.getExe pkgs.helium;
        };

        systemPackages = [
          pkgs.helium
        ];
      };

      xdg.mime.defaultApplications = {
        "text/html" = "helium.desktop";
        "x-scheme-handler/http" = "helium.desktop";
        "x-scheme-handler/https" = "helium.desktop";
        "x-scheme-handler/about" = "helium.desktop";
        "x-scheme-handler/unknown" = "helium.desktop";
      };

      custom.programs.hyprland.settings.windowrule = [
        # Do not idle while watching videos
        "match:class helium, idle_inhibit fullscreen"
        "match:class helium, match:title (.*)(YouTube)(.*), idle_inhibit focus"
        # float save dialogs
        # save as
        "match:initial_class helium, match:initial_title ^(Save File)$, float on, size <50% <50%"
        # save image
        "match:initial_class helium, match:initial_title (.*)(wants to save)$, float on, size <50% <50%"
      ];

      # custom.startup = [
      #   {
      #     app-id = "helium";
      #     spawn = [
      #       (lib.getExe (
      #         pkgs.writeShellApplication {
      #           name = "init-helium";
      #           runtimeInputs = [
      #             pkgs.helium
      #           ];
      #           text = ''
      #             helium --profile-directory=Default &
      #           '';
      #         }
      #       ))
      #     ];
      #     workspace = 1;
      #   }
      # ];

      custom = {
        programs = {
          which-key = {
            menus = {
              h = {
                desc = "Helium";
                cmd = lib.getExe pkgs.helium;
              };
            };
          };
        };
        persist = {
          home.directories = [
            ".cache/net.imput.helium"
            ".config/net.imput.helium"
          ];
        };
      };
    };
}
