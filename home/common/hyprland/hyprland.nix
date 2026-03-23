{
  lib,
  config,
  pkgs,
  inputs,
  machine,
  ...
}:
let
  formatWorkspace =
    m: w:
    "${w.name}, monitor:${m.name}"
    + lib.optionalString w.persistent ", persistent:true"
    + lib.optionalString w.default ", default:true"
    + lib.optionalString (w.layout != null) ", layout:${w.layout}"
    # + lib.optionalString (w.layout_orientation != null) ", layoutopt:orientation:${w.layout_orientation}"
    + lib.optionalString (w.on_created_empty != null) ", on-created-empty:${w.on_created_empty}";

  onStartPrograms = lib.flatten (
    map (
      m:
      map (
        ws:
        lib.optionals ((ws.on_start or null) != null) (
          map (cmd: "[workspace ${ws.name} silent] ${cmd}") ws.on_start
        )
      ) (m.workspaces or [ ])
    ) config.monitors
  );
in
{
  home.packages = with pkgs; [
    ydotool
    hyprpolkitagent
    hyprsunset
    hyprpicker
    bitwarden-cli
    tesseract
    jq
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];

  wayland.windowManager.hyprland = {
    inherit (machine.windowManager.hyprland) enable;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    # plugins = [
    #   inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
    # ];
    systemd = {
      enable = true;
      enableXdgAutostart = false;
      variables = [ "--all" ];
    };
    settings = {
      binds = {
        scroll_event_delay = 50;
        hide_special_on_workspace_change = false;
        allow_workspace_cycles = false;
        workspace_back_and_forth = false;
        window_direction_monitor_fallback = false;
      };

      monitor =
        (map (
          m:
          "${m.name},${
            if m.enabled then
              "${toString m.width}x${toString m.height}@${toString m.refresh_rate}"
              + ",${toString m.x}x${toString m.y},1"
              + ",transform,${toString m.transform}"
              + ",vrr,${toString m.vrr}"
            else
              "disable"
          }"
        ) config.monitors)
        ++ [ " , preferred, auto, 1" ];

      # Workspace
      workspace = lib.flatten (map (m: map (w: formatWorkspace m w) m.workspaces) config.monitors);

      exec-once = [
        "uwsm app -- systemctl --user start hyprpolkitagent"
        (
          if machine.windowManager.hyprland.noctalia.enable then
            "uwsm app -- noctalia-start"
          else
            "killall -q waybar;sleep .5 && uwsm app -- waybar"
        )
        "uwsm app -- nm-applet --indicator"
        "uwsm app -- pypr"
        "snappy-switcher --daemon"
        "sleep 2 && uwsm app -- wallsetter"
        "wl-paste --type text --watch uwsm app -- cliphist store"
        "wl-paste --type image --watch uwsm app -- cliphist store"

        "systemctl --user import-environment $(env | cut -d'=' -f 1)"
        "dbus-update-activation-environment --systemd --all"
      ]
      ++ onStartPrograms;

      input = {
        kb_layout = "us";
        # kb_layout = "us,jp,ru";
        # kb_options = [ "grp:alt_shift_toggle" ];
        numlock_by_default = true;
        repeat_delay = 200;
        repeat_rate = 50;
        follow_mouse = 1;
        float_switch_override_focus = 0;
        sensitivity = 0;
        force_no_accel = true;
      };

      general =
        let
          theme = import ../theme.nix { inherit config; };
          inherit (theme) colors;
          strip = lib.removePrefix "#";
        in
        {
          "$modifier" = "SUPER";
          allow_tearing = true;
          layout = "dwindle";
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          resize_on_border = true;
          "col.active_border" = lib.mkForce "rgb(${strip colors.iris}) rgb(${strip colors.rose}) 45deg";
          "col.inactive_border" = lib.mkForce "rgb(${strip colors.overlay})";
        };

      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc = {
        render_unfocused_fps = 60;
        allow_session_lock_restore = 1;
        force_default_wallpaper = 0;
        layers_hog_keyboard_focus = true;
        initial_workspace_tracking = 1;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
        focus_on_activate = true;
        vfr = true;
        vrr = 1;
      };

      master = {
        new_status = "master";
        new_on_top = 1;
        mfact = 0.5;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      decoration = {
        rounding = 20;
        rounding_power = 2;
        active_opacity = "1.0";
        inactive_opacity = "1.0";

        blur = {
          enabled = true;
          size = 3;
          passes = 2;
          vibrancy = 0.1696;
        };

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };
      };

      cursor = {
        sync_gsettings_theme = true;
        no_hardware_cursors = 2; # change to 1 if want to disable
        enable_hyprcursor = false;
        warp_on_change_workspace = 2;
        no_warps = true;
      };

      render = {
        direct_scanout = 0;
      };

      layerrule = [
        {
          name = "no_anim_for_hyprpicker";
          "match:namespace" = "hyprpicker";
          no_anim = "on";
        }
        {
          name = "no_anim_for_selection";
          "match:namespace" = "selection";
          no_anim = "on";
        }
        {
          name = "no_anim_for_noctalia_launcher";
          "match:namespace" = "noctalia-launcher-overlay-.*$";
          ignore_alpha = 0.5;
          blur = "on";
          blur_popups = "on";
          no_anim = "on";
        }
        {
          name = "noctalia_background";
          "match:namespace" = "noctalia-background-.*$";
          ignore_alpha = 0.5;
          blur = "on";
          blur_popups = "on";
        }
      ];
    };
  };
}
