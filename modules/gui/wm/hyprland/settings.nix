{
  lib,
  ...
}:
{
  flake.modules.nixos.wm =
    {
      config,
      ...
    }:
    let
      inherit (config.custom.constants) host;
      inherit (config.custom.hardware) monitors;

      gap = if host == "xenomorph" then 8 else 4;
      outer = gap * 2;

      # niri app-id float list -> hyprland window rules
      floatClasses = [
        "^org\\.gnome\\.Calculator$"
        "^localsend$"
        "^nm-connection-editor$"
        "^blueman-manager$"
        "^nwg-look$"
        "^qt5ct$"
        "^qt6ct$"
        "^org\\.gnome\\.FileRoller$"
        "^gnome-disks$"
        "^seahorse$"
        "^swayimg$"
        "^com\\.gabm\\.satty$"
        "^vedetector\\.exe$"
      ];

      # media players forced opaque + floating
      mediaClasses = [
        "^mpv$"
        "^vlc$"
        "^imv$"
        "^zoom$"
        "^feh$"
        "^com\\.obsproject\\.Studio$"
        "^capcut\\.exe$"
      ];

      toMonitor =
        d:
        let
          flipped = d.transform >= 4;
          rotation = lib.mod (d.transform * 90) 360;
          transform = if rotation == 0 && !flipped then 0 else d.transform;
        in
        "${d.name},${toString d.width}x${toString d.height}@${toString d.refreshRate},${toString d.x}x${toString d.y},${toString d.scale},transform,${toString transform}";

      toWorkspaceAssign = d: map (ws: "${toString ws}, monitor:${d.name}") d.workspaces;
    in
    {
      custom.programs.hyprland.settings = {
        "$mod" = "SUPER";

        monitor = map toMonitor monitors;

        workspace = lib.flatten (map toWorkspaceAssign monitors);

        general = {
          gaps_in = gap;
          gaps_out = outer;
          border_size = 2;

          # niri focus-ring gradient / inactive color
          "col.active_border" = "rgba(89B4FAff) rgba(94E2D5ff) 45deg";
          "col.inactive_border" = "rgba(1e1e2eff)";

          resize_on_border = true;
          allow_tearing = false;
          layout = "dwindle";
        };

        decoration = {
          rounding = 4;
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          blur = {
            enabled = true;
            size = 8;
            passes = 2;
            noise = 0.02;
            contrast = 1.0;
            brightness = 1.0;
            vibrancy = 0.1696;
            new_optimizations = true;
          };

          shadow = {
            enabled = true;
            range = 30;
            render_power = 3;
            color = "rgba(1a1a1aee)";
            offset = "0 5";
          };
        };

        dwindle = {
          preserve_split = true;
          smart_split = false;
          smart_resizing = false;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
          focus_on_activate = true;
          disable_xdg_env_checks = true;
        };

        input = {
          kb_layout = "us";
          repeat_delay = 200;
          repeat_rate = 50;
          numlock_by_default = true;

          # niri mouse.accel-profile = "flat"
          sensitivity = 0;
          accel_profile = "flat";
          force_no_accel = true;

          # niri focus-follows-mouse with max-scroll-amount 85%
          follow_mouse = 2;

          touchpad = {
            tap-to-click = true;
            disable_while_typing = true;
            natural_scroll = false;
          };
        };

        gesture = [
          "3, horizontal, workspace"
        ];

        cursor = {
          sync_gsettings_theme = true;
          inactive_timeout = 0;
        };

        xwayland = {
          force_zero_scaling = true;
        };

        # mouse drag move / resize
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        # force opaque + floating for media players
        windowrule = lib.flatten [
          (map (c: "match:class ${c}, float on, opacity 1.0") mediaClasses)
          (map (c: "match:class ${c}, float on") floatClasses)
          [
            "match:class ^(steam)$, opacity 1.0"
            "match:class ^(steam)$, match:title ^(Friends List)$, float on"
            "match:class ^(steam)$, match:title ^(Steam - News)$, float on"
            "match:class ^(steam)$, match:title .* - Chat$, float on"

            "match:title ^(Picture-in-Picture)$, float on, size 480 270"
            "match:title ^(Picture in picture)$, float on, size 480 270"

            "match:class ^(xdg-desktop-portal-gtk)$, match:title ^(Open File)$, float on, size 900 600, center on"
            "match:class ^(xdg-desktop-portal-gtk)$, match:title ^(Save File)$, float on, size 900 600, center on"
            "match:class ^(xdg-desktop-portal-gtk)$, match:title ^(Open Folder)$, float on, size 900 600, center on"

            "match:class ^(pavucontrol)$, float on, size 800 600, center on"
            "match:class ^(helium)$, match:title .*Zoom Meeting$, float on, size 800 600, move 100%-832 32"

            "match:class ^(org\\.quickshell)$, opacity 1.0"
          ]
        ];

        layerrule = [
          "match:namespace ^noctalia-overview.*$, ignore_alpha 0, blur on"
          "match:namespace ^quickshell$, ignore_alpha 0, blur on"
          "match:namespace dms:blurwallpaper, ignore_alpha 0, blur on"
        ];
      };
    };
}
