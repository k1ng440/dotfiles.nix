# Keybinds for Hyprland
# Ref: https://wiki.garudalinux.org/en/hyprland-cheatsheet
{
  lib,
  pkgs,
  machine,
  ...
}:
let
  mod = "SUPER";
  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  playerctl = lib.getExe' pkgs.playerctl "playerctl";
  wlogout = lib.getExe' pkgs.wlogout "wlogout";
  hyprlock = lib.getExe' pkgs.hyprlock "hyprlock";
  terminal = "kitty";
  fileManager = "uwsm app -- thunar";
  workspaces = builtins.concatLists [
    (map toString (lib.range 1 9))
    (map (i: "F" + toString i) (lib.range 1 12))
  ];
  directions = rec {
    left = "l";
    right = "r";
    up = "u";
    down = "d";
    h = left;
    j = down;
    k = up;
    l = right;
  };
  noctalia =
    cmd:
    lib.concatStringsSep " " (
      [
        "noctalia-shell"
        "ipc"
        "call"
      ]
      ++ (lib.splitString " " cmd)
    );
in
{
  # Reference of supported bind flags: https://wiki.hyprland.org/Configuring/Binds/#bind-flags
  wayland.windowManager.hyprland.settings = {
    # Mouse Binds
    bindm = [
      "${mod}, mouse:272, movewindow" # hold super + leftlclick  to move/drag active window
      "${mod}, mouse:273, resizewindow" # hold super + rightclick to resize active window
    ];

    # Repeat Binds
    binded = [
      # Zoom
      "${mod}, Z, Zoom In, exec, pypr zoom ++0.5"
      "${mod} SHIFT, Z, Reset Zoom, exec, pypr zoom"

      # Resize active window
      "CTRL ${mod} SHIFT, h, Resize Left, resizeactive,-5 0"
      "CTRL ${mod} SHIFT, j, Resize Down, resizeactive,0 5"
      "CTRL ${mod} SHIFT, k, Resize Up, resizeactive,0 -5"
      "CTRL ${mod} SHIFT, l, Resize Right, resizeactive,5 0"

      "${mod}, minus, Shrink Width, resizeactive, -100 0"
      "${mod}, equal, Grow Width, resizeactive, 100 0"
      "${mod} SHIFT, minus, Shrink Height, resizeactive, 0 -100"
      "${mod} SHIFT, equal, Grow Height, resizeactive, 0 100"
    ];

    bindeld =
      if machine.windowManager.hyprland.noctalia.enable then
        [
          # Volume
          ", XF86AudioRaiseVolume, Increase Volume, exec, ${noctalia "volume increase"}"
          ", XF86AudioLowerVolume, Decrease Volume, exec, ${noctalia "volume decrease"}"

          # Brightness
          ", XF86MonBrightnessDown, Decrease Brightness, exec, ${noctalia "brightness decrease"}"
          ", XF86MonBrightnessUp, Increase Brightness, exec, ${noctalia "brightness increase"}"
        ]
      else
        [
          # Volume
          ", XF86AudioRaiseVolume, Increase Volume, exec, swayosd-client --output-volume raise"
          ", XF86AudioLowerVolume, Decrease Volume, exec, swayosd-client --output-volume lower"

          # Brightness
          ", XF86MonBrightnessDown, Decrease Brightness, exec, hyprctl hyprsunset gamma -10"
          ", XF86MonBrightnessUp, Increase Brightness, exec, hyprctl hyprsunset gamma +10"
        ];

    # Locked Binds (Work even when screen is locked)
    bindld =
      if machine.windowManager.hyprland.noctalia.enable then
        [
          ", XF86AudioMute, Mute Audio, exec, ${noctalia "volume muteOutput"}"
          ", XF86AudioMicMute, Mute Microphone, exec, ${wpctl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ]
      else
        [
          ", XF86AudioMute, Mute Audio, exec, swayosd-client --output-volume mute-toggle"
          ", XF86AudioMicMute, Mute Microphone, exec, swayosd-client --input-volume mute-toggle"
        ];

    bindd =
      lib.flatten [
        # Media Control
        ", XF86AudioPlay, Play/Pause Media, exec, '${playerctl} --ignore-player=firefox,chromium,brave play-pause'"
        ", XF86AudioNext, Next Media, exec, '${playerctl} --ignore-player=firefox,chromium,brave next'"
        ", XF86AudioPrev, Previous Media, exec, '${playerctl} --ignore-player=firefox,chromium,brave previous'"

        (
          if machine.windowManager.hyprland.noctalia.enable then
            [
              "${mod}, space, Toggle Launcher, exec, ${noctalia "launcher toggle"}"
              "${mod}, D, Toggle Launcher, exec, ${noctalia "launcher toggle"}"
              "${mod}, N, Toggle Control Center, exec, ${noctalia "control-center toggle"}"
              "${mod}, Tab, Toggle Overview, exec, ${noctalia "overview toggle"}"
              "${mod}, R, Toggle Launcher, exec, ${noctalia "launcher toggle"}"
              "${mod}, V, Toggle Clipper, exec, ${noctalia "plugin:clipper togglePanel"}"
              "${mod} SHIFT, E, Toggle Power Menu, exec, ${noctalia "plugin:power-menu togglePanel"}"
            ]
          else
            [
              "${mod}, space, App Launcher, exec, rofi -show drun"
              "${mod}, D, App Launcher, exec, rofi -show drun"
              "${mod}, R, App Launcher, exec, fuzzel"
              "${mod}, V, Clipboard Manager, exec, cliphist list | wofi -dmenu | cliphist decode | wl-copy && wl-paste --no-newline | xargs -I {} wtype {}"
              "${mod} SHIFT, E, Logout Menu, exec, ${wlogout}"
            ]
        )

        # "${mod}, Tab, workspace, previous"
        "${mod} SHIFT, C, Center Window, centerwindow" # Center floating windows
        "${mod}, grave, Toggle Scratchpad Terminal, exec, pypr toggle term" # Toggle pyprland terminal scratchpad
        "${mod}, m, Toggle Scratchpad Music, exec, pypr toggle music" # Toggle music scratchpad

        "${mod}, comma, Previous Workspace, workspace, -1" # Previous workspace
        "${mod}, period, Next Workspace, workspace, +1" # Next workspace

        # Group
        "${mod}, W, Toggle Group, togglegroup"
        # "${mod}, G, layoutmsg, togglesplit"

        # Circle Window
        "ALT, Tab, Next Window, exec, snappy-switcher next"
        "ALT SHIFT, Tab, Previous Window, exec, snappy-switcher prev"

        # Full Screen
        "${mod} SHIFT, F, Toggle Fullscreen, fullscreenstate,2 -1" # `internal client`, where `internal` and `client` can be -1 - current, 0 - none, 1 - maximize, 2 - fullscreen, 3 - maximize and fullscreen

        # Float
        "${mod}, F, Toggle Floating, togglefloating" # Float toggle

        "${mod}, P, Toggle Pseudo Tile, pseudo" # toggle pseudotile

        # Apps
        "${mod} ALT, G, Gemini AI, exec, launch-webapp https://gemini.google.com"
        "${mod} ALT, C, Claude AI, exec, launch-webapp https://claude.ai"

        # Split
        # "${mod} ALT, S, togglesplit" # Toggle split

        # Kill active / focus window
        "${mod} SHIFT, Q, Kill Window, killactive"
        "${mod} SHIFT, C, Force Kill Window, forcekillactive"
        "${mod}, C, Kill Window, killactive"

        # Toggle between dwindle and master layout globally
        "${mod} SHIFT, apostrophe, Toggle Layout, exec, hyprctl keyword general:layout \"$(hyprctl getoption general:layout | grep -q 'dwindle' && echo 'master' || echo 'dwindle')\""

        # Reload Hyprland
        "CTRL ALT, Delete, Exit Hyprland, exec, hyprctl 'dispatch exit'"

        # Switch Keyboard Layout
        "ALT, Shift_L, Switch Keyboard Layout, exec, hyprctl switchxkblayout"

        # Lock mouse to current window
        "${mod}, Escape, Lock Cursor to Window, exec, hyprctl keyword \"input:cursor_lock_to_window\" 1"
        # Unlock mouse
        "${mod} SHIFT, Escape, Unlock Cursor from Window, exec, hyprctl keyword \"input:cursor_lock_to_window\" 0"
      ]
      # Move focus from active window to window in specified direction (UP/k, Down/j, Left/h, Right/l)
      ++ (lib.mapAttrsToList (
        key: direction: "${mod}, ${key}, Move Focus ${direction}, movefocus,${direction}"
      ) directions)
      # Move to workspace
      ++ (map (
        n: "${mod} ALT, ${n}, Move Window to Workspace ${n} (silent), movetoworkspacesilent, ${n}"
      ) workspaces)
      # Swap windows
      ++ (lib.mapAttrsToList (
        key: direction: "${mod} SHIFT, ${key}, Move Window ${direction}, movewindow,${direction}"
      ) directions)
      # Switch Workspaces
      ++ (map (n: "${mod}, ${n}, Switch to Workspace ${n}, workspace, ${n}") workspaces)
      # Move Window to Workspaces
      ++ (map (n: "${mod} SHIFT, ${n}, Move Window to Workspace ${n}, movetoworkspace, ${n}") workspaces)
      # Lock screen / Logout / Reload
      ++ [
        "${mod} ALT, L, Lock Screen, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ 0 && ${
          if machine.windowManager.hyprland.noctalia.enable then
            "noctalia-shell ipc call lockScreen lock"
          else
            hyprlock
        }"
        "${mod} ALT, R, Reload Config, exec, reload"
      ]
      # Applications
      ++ [
        "${mod}, Q, Open Terminal, exec, ${terminal}" # Terminal
        "${mod}, E, Open File Manager, exec, ${fileManager}"
        "${mod}, F1, Toggle Gamemode, exec, hyprgamemode" # Toggle Gamemode
        "${mod} SHIFT, P, Color Picker, exec, hyprpicker -a" # Color picker

        # Screenshot
        ", Print, Screenshot Region, exec, hyprcap shot region -w -c -z"
        "SHIFT, Print, Record Region, exec, hyprcap rec region -w"
        "CTRL, Print, Stop Recording, exec, hyprcap rec-stop"
        "ALT, Print, Screenshot Window, exec, hyprcap shot window:active -wcz"
      ];
  };
}
