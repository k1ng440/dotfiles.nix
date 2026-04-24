{
  inputs,
  ...
}:
let
  sessionVariables = {
    DMS_SCREENSHOT_EDITOR = "satty";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
in
{
  flake.modules.nixos.wm =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.dms-shell = {
        enable = true;
        package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
        quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
        systemd = {
          enable = true;
          restartIfChanged = true;
        };

        enableSystemMonitoring = true; # System monitoring widgets (dgop)
        enableVPN = true; # VPN management widget
        enableDynamicTheming = true; # Wallpaper-based theming (matugen)
        enableAudioWavelength = true; # Audio visualizer (cava)
        enableCalendarEvents = true; # Calendar integration (khal)
        enableClipboardPaste = true; # Pasting from the clipboard history (wtype)

        plugins = {
          BingWallpaper = {
            src = pkgs.fetchFromGitHub {
              owner = "max72bra";
              repo = "DankPluginBingWallpaper";
              rev = "963cb40d28710aa0d0b69b6399f1b8fb87a168c7";
              hash = "sha256-j7bT4hjXzGfXscFFF3irHuFkOgcEx/3++8edsLD+nbA=";
            };
          };
          wallpaperCarousel = {
            src = pkgs.fetchFromGitHub {
              owner = "motor-dev";
              repo = "wallpaperCarousel";
              rev = "v0.7.6";
              sha256 = "sha256-KI6h0qFbyck3i4fP3BTrnyrjNO3f2kycjRJeJ0ZpsPM=";
            };
          };
        };
      };

      services.power-profiles-daemon.enable = true;

      environment = lib.mkIf config.programs.dms-shell.enable {
        inherit sessionVariables;
      };

      systemd.user.services.dms = lib.mkIf config.programs.dms-shell.enable {
        environment = sessionVariables;
      };

      custom = {
        programs = {
          niri.settings = {
            # Layer rules from DMS docs
            layer-rules = [
              {
                matches = [ { namespace = "^quickshell$"; } ];
                place-within-backdrop = true;
              }
              {
                matches = [ { namespace = "dms:blurwallpaper"; } ];
                place-within-backdrop = true;
              }
            ];
          };
        };
      };
    };
}
