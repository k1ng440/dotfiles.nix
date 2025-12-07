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
  home.packages = with pkgs; [
    ydotool
    hyprpolkitagent
    hyprsunset
    hyprpicker
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];

  disabledModules = [
    "${inputs.stylix}/modules/hyprland/hm.nix"
  ];

  wayland.windowManager.hyprland = {
    inherit (machine.windowManager.hyprland) enable;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
    ];
    systemd = {
      enable = true;
      enableXdgAutostart = false;
      variables = [ "--all" ];
    };
    settings = {
      env = [
        "QT_IM_MODULE,fcitx"
        "XMODIFIERS,@im=fcitx"
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
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_PLUGIN_PATH QT_QPA_PLATFORM QT_STYLE_OVERRIDE PATH"
        "systemctl --user start hyprpolkitagent"
        "killall -q waybar;sleep .5 && waybar"
        "nm-applet --indicator"
        "pypr &"
        "sleep 2 && wallsetter"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "swayosd-server &"
      ]
      ++ onStartPrograms;

      input = {
        kb_layout = "us,jp";
        kb_options = [ ];
        numlock_by_default = true;
        repeat_delay = 200;
        repeat_rate = 50;
        follow_mouse = 1;
        float_switch_override_focus = 0;
        sensitivity = 0;
      };

      general = {
        "$modifier" = "SUPER";
        layout = "dwindle";
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
        allow_session_lock_restore = 1;
        force_default_wallpaper = 0;
        layers_hog_keyboard_focus = true;
        initial_workspace_tracking = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
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
        rounding = 1;
        rounding_power = 2;
        active_opacity = "1.0";
        inactive_opacity = "1.0";

        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          vibrancy = 0.17;
        };

        shadow = {
          enabled = true;
          range = 5;
          render_power = 4;
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
        direct_scanout = 0;
      };
    };
  };
}
