{
  lib,
  self,
  ...
}:
{
  flake.modules.nixos.wm =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.custom.hardware) monitors;

      dms = call: "dms ipc call ${call}";

      workspaceBinds = lib.flatten (
        self.libCustom.mapWorkspaces (args: [
          "$mod, ${args.key}, workspace, ${args.workspace}"
          "$mod SHIFT, ${args.key}, movetoworkspace, ${args.workspace}"
        ]) monitors
      );
    in
    {
      custom.programs.hyprland.settings = {
        bind = [
          # --- Core System & UI ---
          "ALT, F4, killactive,"
          "$mod, Q, killactive,"
          "$mod, BackSpace, killactive,"
          "CTRL ALT, Delete, exec, ${dms "powermenu toggle"}"
          "$mod, A, exec, ${dms "bar toggle"}"
          "$mod SHIFT, A, exec, noctalia-reload"
          "$mod CTRL, V, exec, ${dms "clipboard toggle"}"
          "$mod, N, exec, ${dms "notifications toggle"}"
          "$mod, apostrophe, exec, ${dms "wallpaperCarousel toggle"}"

          # --- Launcher & Files ---
          "$mod, Return, exec, ghostty"
          "$mod SHIFT, Return, exec, ${dms "spotlight toggle"}"
          "$mod, E, exec, nemo ${config.hj.directory}/Downloads"
          "$mod SHIFT, E, exec, ghostty -e yazi ${config.hj.directory}/Downloads"

          # --- Layout & Utility ---
          "$mod, G, togglefloating,"
          "$mod, C, centerwindow,"
          "$mod, T, togglegroup,"

          # --- Window Management (HJKL) ---
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, K, movewindow, u"

          # --- Navigation ---
          "$mod, grave, cyclenext,"
          "$mod, Tab, workspace, previous"

          # --- Browser (Helium) ---
          "$mod, W, exec, helium"
          "$mod SHIFT, W, exec, helium --incognito"

          # --- Monitor Navigation (Alt + hjkl) ---
          "$mod ALT, H, focusmonitor, l"
          "$mod ALT, J, focusmonitor, d"
          "$mod ALT, K, focusmonitor, u"
          "$mod ALT, L, focusmonitor, r"

          # --- Monitor Movement (Alt + Shift + hjkl) ---
          "$mod ALT SHIFT, H, movecurrentworkspacetomonitor, l"
          "$mod ALT SHIFT, J, movecurrentworkspacetomonitor, d"
          "$mod ALT SHIFT, K, movecurrentworkspacetomonitor, u"
          "$mod ALT SHIFT, L, movecurrentworkspacetomonitor, r"

          # --- Monitor Navigation (Alt + Arrows) ---
          "$mod ALT, Left, focusmonitor, l"
          "$mod ALT, Down, focusmonitor, d"
          "$mod ALT, Up, focusmonitor, u"
          "$mod ALT, Right, focusmonitor, r"

          # --- Monitor Movement (Alt + Shift + Arrows) ---
          "$mod ALT SHIFT, Left, movecurrentworkspacetomonitor, l"
          "$mod ALT SHIFT, Down, movecurrentworkspacetomonitor, d"
          "$mod ALT SHIFT, Up, movecurrentworkspacetomonitor, u"
          "$mod ALT SHIFT, Right, movecurrentworkspacetomonitor, r"

          # --- Shaping & Resizing (Arrows) ---
          "$mod, Left, resizeactive, -50 0"
          "$mod, Right, resizeactive, 50 0"
          "$mod, Up, resizeactive, 0 -50"
          "$mod, Down, resizeactive, 0 50"
          "$mod, F, fullscreen, 0"
          "$mod, Z, fullscreen, 1"

          # --- Workspaces ---
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

          # --- Screenshot ---
          ", Print, exec, dms screenshot"
          "SHIFT, Print, exec, sh -c 'dms screenshot --stdout | ${lib.getExe pkgs.satty} -f -'"
        ]
        ++ workspaceBinds;

        # audio keys work while locked
        bindl = [
          ", XF86AudioLowerVolume, exec, pamixer -d 5"
          ", XF86AudioRaiseVolume, exec, pamixer -i 5"
          ", XF86AudioMute, exec, pamixer -t"
        ];
      };
    };
}
