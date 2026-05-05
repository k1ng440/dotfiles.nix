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
            "Mod+G".toggle-window-floating = _: { };
            "Mod+Shift+G".switch-focus-between-floating-and-tiling = _: { };

            # --- Window Management (HJKL) ---
            "Mod+H".focus-column-or-monitor-left = _: { };
            "Mod+L".focus-column-or-monitor-right = _: { };
            "Mod+J".focus-window-or-workspace-down = _: { };
            "Mod+K".focus-window-or-workspace-up = _: { };

            "Mod+Shift+H".move-column-left-or-to-monitor-left = _: { };
            "Mod+Shift+L".move-column-right-or-to-monitor-right = _: { };
            "Mod+Shift+J".move-window-down-or-to-workspace-down = _: { };
            "Mod+Shift+K".move-window-up-or-to-workspace-up = _: { };

            "Mod+C".center-column = _: { };

            # --- Navigation & Layout ---
            "Mod+Home".focus-column-first = _: { };
            "Mod+End".focus-column-last = _: { };
            "Mod+grave".focus-window-previous = _: { };
            "Mod+Tab".focus-workspace-previous = _: { };
            "Mod+O" = _: {
              props = {
                repeat = false;
              };
              content = {
                toggle-overview = _: { };
              };
            };
            "Mod+Q" = _: {
              props = {
                repeat = false;
              };
              content = {
                close-window = _: { };
              };
            };
            "Mod+BackSpace" = _: {
              props = {
                repeat = false;
              };
              content = {
                close-window = _: { };
              };
            };
            "Mod+Shift+Home".move-column-to-first = _: { };
            "Mod+Shift+End".move-column-to-last = _: { };
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
            "Mod+Alt+H".focus-monitor-left = _: { };
            "Mod+Alt+J".focus-monitor-down = _: { };
            "Mod+Alt+K".focus-monitor-up = _: { };
            "Mod+Alt+L".focus-monitor-right = _: { };

            # --- Monitor Movement (Alt + Shift + hjkl) ---
            "Mod+Alt+Shift+H".move-column-to-monitor-left = _: { };
            "Mod+Alt+Shift+J".move-column-to-monitor-down = _: { };
            "Mod+Alt+Shift+K".move-column-to-monitor-up = _: { };
            "Mod+Alt+Shift+L".move-column-to-monitor-right = _: { };

            # --- Monitor Navigation (Alt + Arrows) ---
            "Mod+Alt+Left".focus-monitor-left = _: { };
            "Mod+Alt+Down".focus-monitor-down = _: { };
            "Mod+Alt+Up".focus-monitor-up = _: { };
            "Mod+Alt+Right".focus-monitor-right = _: { };

            # --- Monitor Movement (Alt + Shift + Arrows) ---
            "Mod+Alt+Shift+Left".move-column-to-monitor-left = _: { };
            "Mod+Alt+Shift+Down".move-column-to-monitor-down = _: { };
            "Mod+Alt+Shift+Up".move-column-to-monitor-up = _: { };
            "Mod+Alt+Shift+Right".move-column-to-monitor-right = _: { };

            # --- Shaping & Resizing (Arrows) ---
            "Mod+Left".set-column-width = "-10%";
            "Mod+Right".set-column-width = "+10%";
            "Mod+Up".set-window-height = "-10%";
            "Mod+Down".set-window-height = "+10%";

            "Mod+R".switch-preset-column-width = _: { };
            "Mod+Shift+R".switch-preset-window-height = _: { };
            "Mod+F".fullscreen-window = _: { };
            "Mod+Z".maximize-column = _: { };
            "Mod+Shift+F".expand-column-to-available-width = _: { };

            # --- Multimedia ---
            "XF86AudioLowerVolume" = _: {
              props = {
                allow-when-locked = true;
              };
              content = {
                spawn = [
                  "pamixer"
                  "-d"
                  "5"
                ];
              };
            };
            "XF86AudioRaiseVolume" = _: {
              props = {
                allow-when-locked = true;
              };
              content = {
                spawn = [
                  "pamixer"
                  "-i"
                  "5"
                ];
              };
            };
            "XF86AudioMute" = _: {
              props = {
                allow-when-locked = true;
              };
              content = {
                spawn = [
                  "pamixer"
                  "-t"
                ];
              };
            };

            # --- Mouse / Trackball Optimization ---
            "Mod+Shift+WheelScrollDown" = _: {
              content = {
                focus-workspace-down = _: { };
              };
              props = {
                cooldown-ms = 150;
              };
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
