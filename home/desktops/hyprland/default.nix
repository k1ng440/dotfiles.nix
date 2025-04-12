{inputs, pkgs, lib, config, ...}: {
  imports = [
    ./binds.nix
    ./scripts.nix
    # ./hyprlock.nix
    # ./wlogout.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    systemd = {
      enable = true;
      variables = [ "--all" ]; # fix for https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user enable hyprland-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };

    plugins = [
      # inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
      # inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
      # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
    ];

    settings = {
      env = [
        "NIXOS_OZONE_WL, 1" # for ozone-based and electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND, 1" # for firefox to run on wayland
        "MOZ_WEBRENDER, 1" # for firefox to run on wayland
        "XDG_SESSION_TYPE,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
        "WLR_RENDERER_ALLOW_SOFTWARE,1"
        "QT_QPA_PLATFORM,wayland"
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
      ];

      cursor = {
        no_hardware_cursors = true;
      };

      monitor = (
        map (
          m:
          "${m.name},${
          if m.enabled then
            "${toString m.width}x${toString m.height}@${toString m.refreshRate}"
            + ",${toString m.x}x${toString m.y},1"
            + ",transform,${toString m.transform}"
            + ",vrr,${toString m.vrr}"
          else
            "disable"
        }"
        ) (config.monitors)
      );

      workspace = (
        let
          workspaceIDs = lib.flatten [
            (lib.range 0 9) # workspaces 0 through 9
            "special" # add the special/scratchpad ws
          ];
        in
        # workspace structure to build "[workspace], monitor:[name], default:[bool], persistent:[bool]"
        map (
          ws:
          lib.concatMapStrings (
            m:
            if toString ws == m.workspace then
              "${toString ws}, monitor:${m.name}, default:true, persistent:true"
            else
            if (ws == 1 || ws == "special") && m.primary == true then
              "${toString ws}, monitor:${m.name}, default:true, persistent:true"
            else
              ""
          ) config.monitors
        ) workspaceIDs
      );

      binds = {
        workspace_center_on = 1; # Whether switching workspaces should center the cursor on the workspace (0) or on the last active window for that workspace (1)
        movefocus_cycles_fullscreen = false; # If enabled, when on a fullscreen window, movefocus will cycle fullscreen, if not, it will move the focus in a direction.
      };

      input = {
        # keyboard
        kb_layout = "us";
        repeat_rate = 50;
        repeat_delay = 200;

        # follow_mouse options:
        # 0 - Cursor movement will not change focus.
        # 1 - Cursor movement will always change focus to the window under the cursor.
        # 2 - Cursor focus will be detached from keyboard focus. Clicking on a window will move keyboard focus to that window.
        # 3 - Cursor focus will be completely separate from keyboard focus. Clicking on a window will not change keyboard focus.
        follow_mouse = 2;

        mouse_refocus = false;
      };

      cursor.inactive_timeout = 10;

      misc = {
        disable_hyprland_logo = true;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        #disable_autoreload = true;
        new_window_takes_over_fullscreen = 2; # 0 - behind, 1 - takes over, 2 - unfullscreen/unmaxize
        middle_click_paste = false;
      };

      windowrule = [
        # Dialogs
        "float, title:^(Open File)(.*)$"
        "float, title:^(Select a File)(.*)$"
        "float, title:^(Choose wallpaper)(.*)$"
        "float, title:^(Open Folder)(.*)$"
        "float, title:^(Save As)(.*)$"
        "float, title:^(Library)(.*)$"
        "float, title:^(Accounts)(.*)$"
        "float, title:^(Print)(.*)$"
        "float, title:^(Settings)(.*)$"
        "float, title:^(Preferences)(.*)$"
        "float, title:^(Confirm)(.*)$"
        "float, title:^(Warning)(.*)$"
        "float, title:^(Error)(.*)$"
        "float, title:^(About)(.*)$"
      ];

      windowrulev2 = [
        # Ignore maximize requests from apps. You'll probably like this.
        "suppressevent maximize, class:.*"
        # Fix some dragging issues with XWayland
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"

        # Floating
        "float, class:^(galculator)$"
        "float, class:^(waypaper)$"

        # Always opaque
        "opaque, class:^([Gg]imp)$"
        "opaque, class:^([Ff]lameshot)$"
        "opaque, class:^([Ii]nkscape)$"
        "opaque, class:^([Bb]lender)$"
        "opaque, class:^([Oo][Bb][Ss])$"
        "opaque, class:^([Ss]team)$"
        "opaque, class:^([Ss]team_app_*)$"
        "opaque, class:^([Vv]lc)$"

        # Remove transparency from video
        "opaque, title:^(Netflix)(.*)$"
        "opaque, title:^(.*YouTube.*)$"
        "opaque, title:^(Picture-in-Picture)$"

        # Steam rules
        "minsize 1 1, title:^()$,class:^([Ss]team)$"
        "immediate, class:^([Ss]team_app_*)$"
        "workspace 7, class:^([Ss]team_app_*)$"
        "monitor 0, class:^([Ss]team_app_*)$"

        # Workspace Assignments
        "workspace 8, class:^(virt-manager)$"
        "workspace 8, class:^(obsidian)$"
        "workspace 9, class:^(brave-browser)$"
        "workspace 9, class:^(signal)$"
        "workspace 9, class:^(org.telegram.desktop)$"
        "workspace 9, class:^(discord)$"
        "workspace 0, title:^([Ss]potify*)$"
      ];


      exec-once = [
        "systemctl --user enable --now hyprpaper.service"
        "waybar"
      ];
    };
  };
}
