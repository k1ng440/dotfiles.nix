# This might be useful to adopt some keybinds. https://wiki.garudalinux.org/en/hyprland-cheatsheet

{ config, lib, pkgs, ... }:
let
  mod = "SUPER";
  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  brightnessctl = lib.getExe' pkgs.brightnessctl "brightnessctl";
  playerctl = lib.getExe' pkgs.playerctl "playerctl";
  wlogout = lib.getExe' pkgs.wlogout "wlogout";
  hyprlock = lib.getExe' pkgs.hyprlock "hyprlock";
  terminal = "kitty";
  fileManager = "thunar";
  workspaces = builtins.concatLists [
    (map toString (lib.range 1 9))
    (map (i: "F" + toString i) (lib.range 1 12))
  ];
  directions = rec { left = "l"; right = "r"; up = "k"; down = "j"; h = left; l = right; k = up; j = down; };
in {
  # Reference of supported bind flags: https://wiki.hyprland.org/Configuring/Binds/#bind-flags
  wayland.windowManager.hyprland.settings = {
    # Mouse Binds
    bindm = [
      "${mod}, mouse:272, movewindow" # hold super + leftlclick  to move/drag active window
      "${mod}, mouse:273, resizewindow" # hold super + rightclick to resize active window
    ];

    # Repeat Binds
    binde = [
      # Resize active window 5 pixels in direction
      "CTRL SUPER SHIFT, h, resizeactive,-5 0"
      "CTRL SUPER SHIFT, j, resizeactive,0 5"
      "CTRL SUPER SHIFT, k, resizeactive,0 -5"
      "CTRL SUPER SHIFT, l, resizeactive,5 0"

      # Volume
      ", XF86AudioRaiseVolume, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ 0 && ${wpctl} set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ 0 && ${wpctl} set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"

      # Brightness
      ", XF86MonBrightnessUp, exec, ${brightnessctl} s 10%+"
      ", XF86MonBrightnessDown, exec, ${brightnessctl} s 10%-"
    ];

    bind = [
      # Mute Toggle
      ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMute, exec, ${wpctl} set-source-mute @DEFAULT_SOURCE@ toggle"
      # Media Control
      ", XF86AudioPlay, exec, '${playerctl} --ignore-player=firefox,chromium,brave play-pause'"
      ", XF86AudioNext, exec, '${playerctl} --ignore-player=firefox,chromium,brave next'"
      ", XF86AudioPrev, exec, '${playerctl} --ignore-player=firefox,chromium,brave previous'"
    ] ++ [
        "${mod}, , exec, rofi -show drun"           # App launcher
        "${mod}, space, exec, rofi -show drun"      # App launcher
        "${mod}, R, exec, rofi -show drun"          # App launcher
        # TODO:  Window switcher

        # Full Screen
        "${mod}, F, fullscreenstate,2 -1" # `internal client`, where `internal` and `client` can be -1 - current, 0 - none, 1 - maximize, 2 - fullscreen, 3 - maximize and fullscreen

        # Float
        "${mod} SHIFT, F, togglefloating"   # Float toggle
        "${mod} SHIFT, P, pin, active"      # pins a floating window (i.e. show it on all workspaces)

        # Split
        "${mod} ALT, S, togglesplit"  # Toggle split

        # Kill active / focus window
        "${mod} SHIFT, Q, killactive"
        "${mod}, C, killactive"
      ]
      # Move focus from active window to window in specified direction (UP/k, Down/j, Left/h, Right/l)
      ++ (lib.mapAttrsToList (key: direction: "${mod}, ${key}, movefocus,${direction}") directions)
      # Swap windows
      ++ (lib.mapAttrsToList (key: direction: "${mod} SHIFT, ${key}, swapwindow,${direction}") directions)
      # Switch Workspaces
      ++ (map (n: "${mod}, ${n}, workspace, name:${n}") workspaces)
      # Move Window to Workspaces
      ++ (map (n: "${mod} SHIFT, ${n}, movetoworkspace, name:${n}") workspaces)
      # Special Workspace
      ++ [
        "${mod}, S, togglespecialworkspace, magic"
        "${mod} SHIFT, S, movetoworkspace, special:magic"
      ]
      # Lock screen / Logout / Reload
      ++ [
        "SUPER, L, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ 0 && ${hyprlock}"
        "SUPER SHIFT, E, exec, ${wlogout}"
        "SUPER SHIFT, R, exec, reload"
      ]
      # Applications
      ++ [
        "${mod}, Q, exec, ${terminal}" # Terminal
        "${mod}, E, exec, ${fileManager}"
        ", Print, exec, screenshootin"
      ]
      ;
  };
}
