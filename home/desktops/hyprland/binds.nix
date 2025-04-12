#NOTE: Actions prepended with `hy3;` are specific to the hy3 hyprland plugin
{ config, lib, pkgs, ... }: {
  wayland.windowManager.hyprland.settings = {
    # Reference of supported bind flags: https://wiki.hyprland.org/Configuring/Binds/#bind-flags

    # Mouse Binds
    bindm = [
      # hold alt + leftlclick  to move/drag active window
      "ALT,mouse:272,movewindow"
      # hold alt + rightclick to resize active window
      "ALT,mouse:273,resizewindow"
    ];

    # Non-consuming Binds
    # bindn = [
    #   # allow tab selection using mouse
    #   ", mouse:272, hy3:focustab, mouse"
    # ];

    # Repeat Binds
    binde = let
      wpctl = lib.getExe' pkgs.wireplumber "wpctl";
      brightnessctl = lib.getExe' pkgs.brightnessctl "brightnessctl";
    in
      [
      # Resize active window 5 pixels in direction
      "Control_L&Shift_L&Alt_L, h, resizeactive, -5 0"
      "Control_L&Shift_L&Alt_L, j, resizeactive, 0 5"
      "Control_L&Shift_L&Alt_L, k, resizeactive, 0 -5"
      "Control_L&Shift_L&Alt_L, l, resizeactive, 5 0"

      # Volume
      ", XF86AudioRaiseVolume, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ 0 && ${wpctl} set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ 0 && ${wpctl} set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"

      # Brightness
      ",XF86MonBrightnessUp, exec, ${brightnessctl} s 10%+"
      ",XF86MonBrightnessDown, exec, ${brightnessctl} s 10%-"
    ];
    #
    # ========== One-shot Binds ==========
    #
    bind =
      let
        mainMod = "SUPER";
        workspaces = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "F1" "F2" "F3" "F4" "F5" "F6" "F7" "F8" "F9" "F10" "F11" "F12" ];
        # Map keys (arrows and hjkl) to hyprland directions (l, r, u, d)
        directions = rec {
          left = "h";
          right = "l";
          up = "k";
          down = "j";
          h = left;
          l = right;
          k = up;
          j = down;
        };
        wpctl = lib.getExe' pkgs.wireplumber "wpctl";
        terminal = "kitty";
        fileManager = "thunar";
      in
        lib.flatten [
          "ALT, space, exec, rofi -show drun"             # App launcher
          "${mainMod}, space, exec, rofi -show drun"      # App launcher (alternate)
          "${mainMod}, R, exec, rofi -show drun"          # App launcher (quick)
          "SHIFT_ALT, space, exec, rofi -show run"        # Run command
          "${mainMod}, S, exec, rofi -show ssh"           # SSH launcher
          "ALT, TAB, exec, rofi -show window"             # Window switcher

          # Mute Toggle
          ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMute, exec, ${wpctl} set-source-mute @DEFAULT_SOURCE@ toggle"

          # Media Control
          ", XF86AudioPlay, exec, 'playerctl --ignore-player=firefox,chromium,brave play-pause'"
          ", XF86AudioNext, exec, 'playerctl --ignore-player=firefox,chromium,brave next'"
          ", XF86AudioPrev, exec, 'playerctl --ignore-player=firefox,chromium,brave previous'"

          # Close the focused/active window
          # "SHIFTALT, q, hy3:killactive"
          "SHIFTALT, Q, killactive"
          "${mainMod}, C, killactive"

          # Full screen
          "${mainMod}, F, fullscreenstate,2 -1" # `internal client`, where `internal` and `client` can be -1 - current, 0 - none, 1 - maximize, 2 - fullscreen, 3 - maximize and fullscreen

          # Float toggle
          "SHIFTALT, F, togglefloating"
          # Pin Active Floatting window
          "SHIFTALT, P, pin, active" # pins a floating window (i.e. show it on all workspaces)

          # Splits groups
          # "${mainMod}, V, hy3:makegroup,v"           # Make a vertical split
          # "SHIFTALT, V, hy3:makegroup,h"             # Make a horizontal split
          # "${mainMod}, X, hy3:changegroup,opposite"  # Toggle btwn splits if untabbed
          "${mainMod}, S, togglesplit"               # Toggle split

          # Workspaces
          (map (n: "${mainMod}, ${n}, workspace, name:${n}") workspaces)
          (map (n: "${mainMod} SHIFT, ${n}, movetoworkspace, name:${n}") workspaces)
          # (map (n: "${mainMod} SHIFT, ${n},hy3:movetoworkspace,name:${n}") workspaces)

          # Special Workspace
          "${mainMod}, S, togglespecialworkspace, magic"
          "${mainMod} SHIFT, S, movetoworkspace, special:magic"

          # Scroll through existing workspaces with mainMod + scroll
          "${mainMod}, mouse_down, workspace, e+1"
          "${mainMod}, mouse_up, workspace, e-1"

          # Move focus from active window to window in specified direction
          # (lib.mapAttrsToList (key: direction: "${mainMod}, ${key}, hy3:movefocus,${direction},warp") directions)

          # Move windows
          # (lib.mapAttrsToList (key: direction: "SUPER SHIFT, ${key}, hy3:movewindow,${direction}") directions)

          # Move workspace to monitor in specified direction
          (lib.mapAttrsToList (
            key: direction: "CTRLSHIFT, ${key}, movecurrentworkspacetomonitor,${direction}"
          ) directions)

          "SHIFTALT, R, exec, hyprctl reload"  # reload the configuration file
          "SUPER, L, exec, hyprlock"           # lock the wm
          "SUPER, E, exec, wlogout"            # lock the wm

          # Application shortcuts
          "${mainMod}, Q, exec, ${terminal}" # Terminal
          "${mainMod}, E, exec, ${fileManager}"
        ];
  };
}
