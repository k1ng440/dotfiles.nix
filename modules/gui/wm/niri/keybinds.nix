{ lib, self, ... }:
{
  flake.modules.nixos.wm =
    { pkgs, config, ... }:
    let
      # inherit (config.custom.constants) dots projects;
      inherit (config.custom.hardware) monitors;
      termExec =
        cmd:
        [
          "ghostty"
          "-e"
        ]
        ++ (lib.flatten cmd);
    in
    {
      custom = {
        programs.niri.settings = {
          binds = {
            # --- Core System & UI ---
            "Mod+Shift+Slash".show-hotkey-overlay = null;
            "Alt+F4".quit = null;
            "Ctrl+Alt+Delete".spawn = [
              "dms"
              "ipc"
              "call"
              "powermenu"
              "toggle"
            ];
            "Mod+A".spawn = [
              "dms"
              "ipc"
              "call"
              "bar"
              "toggle"
            ];
            "Mod+Shift+A".spawn = [ "noctalia-reload" ];
            "Mod+Escape".toggle-keyboard-shortcuts-inhibit = null;
            "Mod+Ctrl+V".spawn = [
              "dms"
              "ipc"
              "call"
              "clipboard"
              "toggle"
            ];
            "Mod+N".spawn = [
              "dms"
              "ipc"
              "call"
              "notifications"
              "toggle"
            ];
            "Mod+Apostrophe".spawn = [
              "dms"
              "ipc"
              "call"
              "wallpaperCarousel"
              "toggle"
            ];

            # --- Launcher & Files ---
            "Mod+Return".spawn = [ "ghostty" ];
            "Mod+Shift+Return".spawn = [
              "dms"
              "ipc"
              "call"
              "spotlight"
              "toggle"
            ];
            "Mod+E".spawn = [
              "nemo"
              "${config.hj.directory}/Downloads"
            ];
            "Mod+Shift+E".spawn = termExec [
              "yazi"
              "${config.hj.directory}/Downloads"
            ];

            # --- Layout & Utility ---
            "Mod+G".toggle-window-floating = null;
            "Mod+Shift+G".switch-focus-between-floating-and-tiling = null;

            # --- Window Management (HJKL) ---
            "Mod+H".focus-column-or-monitor-left = null;
            "Mod+L".focus-column-or-monitor-right = null;
            "Mod+J".focus-window-or-workspace-down = null;
            "Mod+K".focus-window-or-workspace-up = null;

            "Mod+Shift+H".move-column-left-or-to-monitor-left = null;
            "Mod+Shift+L".move-column-right-or-to-monitor-right = null;
            "Mod+Shift+J".move-window-down-or-to-workspace-down = null;
            "Mod+Shift+K".move-window-up-or-to-workspace-up = null;

            "Mod+C".center-column = null;

            # --- Navigation & Layout ---
            "Mod+Home".focus-column-first = null;
            "Mod+End".focus-column-last = null;
            "Mod+grave".focus-window-previous = null;
            "Mod+Tab".focus-workspace-previous = null;
            "Mod+O" = {
              toggle-overview = null;
              _attrs.repeat = false;
            };
            "Mod+Q" = {
              close-window = null;
              _attrs.repeat = false;
            };
            "Mod+BackSpace" = {
              close-window = null;
              _attrs.repeat = false;
            };
            "Mod+Shift+Home".move-column-to-first = null;
            "Mod+Shift+End".move-column-to-last = null;
            "Mod+Shift+Tab".spawn = [
              "sh"
              "-c"
              "niri msg action focus-column-right; niri msg action move-column-to-last; niri msg action focus-window-previous"
            ];

            # --- Browser (Helium) ---
            "Mod+W".spawn = [
              "sh"
              "-c"
              "helium &"
            ];
            "Mod+Shift+W".spawn = [
              "sh"
              "-c"
              "helium --incognito &"
            ];

            # --- Monitor Navigation (Alt + hjkl) ---
            "Mod+Alt+H".focus-monitor-left = null;
            "Mod+Alt+J".focus-monitor-down = null;
            "Mod+Alt+K".focus-monitor-up = null;
            "Mod+Alt+L".focus-monitor-right = null;

            # --- Monitor Movement (Alt + Shift + hjkl) ---
            "Mod+Alt+Shift+H".move-column-to-monitor-left = null;
            "Mod+Alt+Shift+J".move-column-to-monitor-down = null;
            "Mod+Alt+Shift+K".move-column-to-monitor-up = null;
            "Mod+Alt+Shift+L".move-column-to-monitor-right = null;

            # --- Monitor Navigation (Alt + Arrows) ---
            "Mod+Alt+Left".focus-monitor-left = null;
            "Mod+Alt+Down".focus-monitor-down = null;
            "Mod+Alt+Up".focus-monitor-up = null;
            "Mod+Alt+Right".focus-monitor-right = null;

            # --- Monitor Movement (Alt + Shift + Arrows) ---
            "Mod+Alt+Shift+Left".move-column-to-monitor-left = null;
            "Mod+Alt+Shift+Down".move-column-to-monitor-down = null;
            "Mod+Alt+Shift+Up".move-column-to-monitor-up = null;
            "Mod+Alt+Shift+Right".move-column-to-monitor-right = null;

            # --- Shaping & Resizing (Arrows) ---
            "Mod+Left".set-column-width = "-10%";
            "Mod+Right".set-column-width = "+10%";
            "Mod+Up".set-window-height = "-10%";
            "Mod+Down".set-window-height = "+10%";

            "Mod+R".switch-preset-column-width = null;
            "Mod+Shift+R".switch-preset-window-height = null;
            "Mod+F".fullscreen-window = null;
            "Mod+Z".maximize-column = null;
            "Mod+Shift+F".expand-column-to-available-width = null;

            # --- Multimedia ---
            "XF86AudioLowerVolume" = {
              spawn = [
                "pamixer"
                "-d"
                "5"
              ];
              _attrs.allow-when-locked = true;
            };
            "XF86AudioRaiseVolume" = {
              spawn = [
                "pamixer"
                "-i"
                "5"
              ];
              _attrs.allow-when-locked = true;
            };
            "XF86AudioMute" = {
              spawn = [
                "pamixer"
                "-t"
              ];
              _attrs.allow-when-locked = true;
            };

            # --- Mouse / Trackball Optimization ---
            "Mod+Shift+WheelScrollDown" = {
              focus-workspace-down = null;
              _attrs.cooldown-ms = 150;
            };
            "Mod+Shift+WheelScrollUp" = {
              focus-workspace-up = null;
              _attrs.cooldown-ms = 150;
            };
            "Mod+WheelScrollRight".focus-column-right = null;
            "Mod+WheelScrollLeft".focus-column-left = null;

            "Mod+BracketLeft".consume-or-expel-window-left = null;
            "Mod+BracketRight".consume-or-expel-window-right = null;

            # Center all fully visible columns on screen.
            "Mod+Ctrl+C".center-visible-columns = null;

            "Mod+T".toggle-column-tabbed-display = null;

            # --- Screenshot ---
            "Print".spawn = [
              "dms"
              "screenshot"
            ];
            "Shift+Print".spawn = [
              "sh"
              "-c"
              "dms screenshot --stdout | ${lib.getExe pkgs.satty} -f -"
            ];
          }
          // lib.mergeAttrsList (
            lib.flatten (
              (self.libCustom.mapWorkspaces (
                { workspace, key, ... }:
                [
                  {
                    # Switch workspaces with Mod + [0-9]
                    "Mod+${key}".focus-workspace = toString workspace;
                    # Move active window to a workspace with Mod + SHIFT + [0-9]
                    "Mod+Shift+${key}".move-window-to-workspace = toString workspace;
                  }
                ]
              ))
                monitors
            )
          );
        };
      };
    };
}
