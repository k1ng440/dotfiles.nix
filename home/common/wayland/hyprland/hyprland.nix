{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  formatWorkspace =
    m: w:
    "${w.name}, monitor:${m.name}"
    + lib.optionalString w.persistent ", persistent:true"
    + lib.optionalString w.default ", default:true"
    + lib.optionalString (w.layout != null) ", layout:${w.layout}"
    + lib.optionalString (w.layout_orientation != null) ", orientation:${w.layout_orientation}"
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

  imports = [
    ../common/packages.nix
  ];

  home.packages = with pkgs; [
    ydotool
    hyprpolkitagent
    hyprsunset
    hyprshot
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];

  disabledModules = [
    "${inputs.stylix}/modules/hyprland/hm.nix"
  ];

  wayland.windowManager.hyprland = {
    enable = false;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    systemd = {
      enable = true;
      enableXdgAutostart = false;
      variables = [ "--all" ];
    };
    settings = {
      env = [
        "QP_QPA_PLATFORM,wayland;xcb"
      ];

      monitor = map (
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
      ) config.monitors;

      # Workspace
      workspace = lib.flatten (map (m: map (w: formatWorkspace m w) m.workspaces) config.monitors);

      exec-once = [
        "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprpolkitagent"
        "killall -q waybar;sleep .5 && waybar"
        "nm-applet --indicator"
        "pypr &"
        "sleep 2 && wallsetter"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ] ++ onStartPrograms;

      input = {
        kb_layout = "us";
        kb_options = [ ];
        numlock_by_default = true;
        repeat_delay = 200;
        repeat_rate = 50;
        follow_mouse = 1;
        float_switch_override_focus = 0;
        sensitivity = 0;
      };

      gestures = {
        workspace_swipe = 1;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 500;
        workspace_swipe_invert = 1;
        workspace_swipe_min_speed_to_force = 30;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = 1;
        workspace_swipe_forever = 1;
      };

      general = {
        "$modifier" = "SUPER";
        layout = "master";
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        resize_on_border = true;
        "col.active_border" =
          "rgb(${config.lib.stylix.colors.base08}) rgb(${config.lib.stylix.colors.base0C}) 45deg";
        "col.inactive_border" = "rgb(${config.lib.stylix.colors.base01})";
      };

      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc = {
        layers_hog_keyboard_focus = true;
        initial_workspace_tracking = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = false;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
        focus_on_activate = true;
        vfr = true;
        vrr = 0;
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
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          ignore_opacity = false;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
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
        explicit_sync = 1; # Change to 1 to disable
        explicit_sync_kms = 1;
        direct_scanout = 0;
      };
    };
  };
}
