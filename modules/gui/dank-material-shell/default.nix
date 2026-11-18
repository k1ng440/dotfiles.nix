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
      lib,
      pkgs,
      ...
    }:
    let
      # Noctalia v5 is the desktop shell now. DMS is kept here in full so
      # switching back is a one-word change; nothing below is evaluated while
      # this is false.
      dmsEnabled = false;

      # Start DMS as part of the WM session, not the generic
      # graphical-session.target: the latter activates at login before the
      # compositor's Wayland socket exists, so dms crashes (qt.qpa.wayland
      # "Could not create EGL surface" / connection refused), hits the restart
      # limit, and never comes back once the compositor is actually up.
      #
      # Bind to both WM session targets instead of deciding which WM runs at
      # build time: config.custom.specialisation.current only reflects boots
      # via a specialisation, not sessions picked at the ly login screen. Only
      # the session target of the currently running compositor is ever started,
      # so whichever of these is inactive is a no-op.
      dmsTargets = [
        "niri-session.target"
        "hyprland-session.target"
      ];
    in
    {
      programs.dms-shell = lib.mkIf dmsEnabled {
        enable = true;
        package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
        quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
        systemd = {
          enable = true;
          restartIfChanged = true;
          # Single target here; both WM session targets are wired up explicitly
          # in systemd.user.services.dms below (wantedBy/partOf/after union).
          target = lib.head dmsTargets;
        };

        enableVPN = true; # VPN management widget
        enableDynamicTheming = true; # Wallpaper-based theming (matugen)
        enableAudioWavelength = true; # Audio visualizer (cava)
        enableCalendarEvents = true; # Calendar integration (khal)

        plugins = {
          BingWallpaper = {
            src = pkgs.fetchFromGitHub {
              owner = "max72bra";
              repo = "DankPluginBingWallpaper";
              rev = "963cb40d28710aa0d0b69b6399f1b8fb87a168c7";
              hash = "sha256-j7bT4hjXzGfXscFFF3irFuFkOgcEx/3++8edsLD+nbA=";
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

      # NOTE: settings.json is deliberately NOT managed here. DMS's writability probe
      # is `[ ! -f PATH ] || [ -w PATH ]`, so a store-backed file (mode 444, root-owned,
      # symlinked in by smfh) always reads as read-only: DMS then refuses to persist any
      # edit made in its settings UI. Let DMS own the file and change it from the UI.

      # power-profiles-daemon is left enabled unconditionally: DMS wanted it, and
      # noctalia v5 drives the same UPower profiles (`noctalia msg power-cycle`).
      services.power-profiles-daemon.enable = true;

      environment = lib.mkIf dmsEnabled {
        inherit sessionVariables;
      };

      systemd.user.services.dms = lib.mkIf dmsEnabled {
        environment = sessionVariables;
        # The packaged dms.service hardcodes graphical-session.target; rebind
        # its lifecycle to both WM session targets. wantedBy/partOf/after are
        # list options, so this unions with the WantedBy generated from
        # programs.dms-shell.systemd.target instead of replacing it.
        partOf = dmsTargets;
        after = dmsTargets;
        wantedBy = dmsTargets;
      };

      custom = {
        programs = {
          niri.settings = {
            # Layer rules from DMS docs. The `dms:blurwallpaper` rule is dropped:
            # that namespace only exists while DMS runs. `^quickshell$` stays,
            # since other quickshell surfaces may still use it.
            layer-rules = [
              {
                matches = [ { namespace = "^quickshell$"; } ];
                place-within-backdrop = true;
              }
            ];
          };
        };
      };
    };
}
