{
  config,
  pkgs,
  lib,
  machine,
  ...
}:
let
  mod = "Mod4";
  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  brightnessctl = lib.getExe' pkgs.brightnessctl "brightnessctl";
  playerctl = lib.getExe' pkgs.playerctl "playerctl";
  logout = lib.getExe' pkgs.nwg-bar "nwg-bar";
  hyprlock = lib.getExe' pkgs.hyprlock "hyprlock";
  terminal = "kitty";
  fileManager = "thunar";
  menu = pkgs.writeShellScript "rofi-menu.sh" ''
    		monitor="$(swaymsg -t get_outputs | jq '.[] | select(.focused) | .name' -r)"
    		${pkgs.rofi}/bin/rofi -show drun -modi drun -monitor "$monitor" $@
    	'';
in
{
  imports = [] ++ lib.optionals machine.windowManager.sway.enable [
    ../common/packages.nix
    ../swappy.nix
    # ./scripts
  ];

  home.packages = with pkgs; [
    dex # Program to generate and execute DesktopEntry files of the Application type
    xorg.xrandr
    swayosd
  ];

  home.sessionVariables = lib.mkIf machine.windowManager.sway.enable {
    XDG_CONFIG_HOME = "$HOME/.config";
    GTK_USE_PORTAL = "1";
    XDG_SESSION_DESKTOP = "sway";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1"; # Fix for Java based applications
  };

  wayland.windowManager.sway = {
    enable = machine.windowManager.sway.enable;
    wrapperFeatures.gtk = true;
    config = {
      modifier = mod;
      terminal = terminal;
      menu = menu;

      focus = {
        followMouse = "yes";
        newWindow = "smart";
      };

      # Startup programs
      startup =
        let
          workspaceActivateCommands = lib.concatMap (
            m:
            lib.filter (cmd: cmd != { }) (
              map (w: {
                command = "swaymsg 'workspace ${w.name}";
                always = true;
              }) m.workspaces
            )
          ) config.monitors;

          workspaceStartupCommands = lib.concatMap (
            m:
            lib.filter (cmd: cmd != { }) (
              map (
                w:
                if (w.on_start or null) != null && w.on_start != [ ] then
                  {
                    command = "swaymsg 'workspace ${w.name}; exec ${lib.concatStringsSep " && " w.on_start}'";
                  }
                else
                  { }
              ) m.workspaces
            )
          ) config.monitors;
        in
        workspaceActivateCommands
        ++ workspaceStartupCommands
        ++ [
          {
            command = "exec systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME";
          }
          {
            command = "exec dbus-update-activation-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME";
          }
          { command = "exec nm-applet --indicator"; }
          { command = "exec wl-paste --type text --watch cliphist store"; }
          { command = "exec wl-paste --type image --watch cliphist store"; }
          { command = "exec swayosd-server"; }
          {
            command = "systemctl --user start sway-session.target";
            always = true;
          }
          {
            command = "xrandr --output $(xrandr | grep -m 1 XWAYLAND | awk '{print $1;}') --primary";
            always = true;
          }
        ];

      # Workspace assignments
      workspaceOutputAssign = lib.concatMap (
        m:
        map (w: {
          workspace = w.name;
          output = m.name;
        }) m.workspaces
      ) config.monitors;

      # Monitor configuration
      output = lib.listToAttrs (
        map (m: {
          name = m.name;
          value = {
            mode = "${toString m.width}x${toString m.height}@${toString m.refresh_rate}Hz";
            position = "${toString m.x},${toString m.y}";
            transform = toString m.transform;
          };
        }) config.monitors
      );

      keybindings = {
        # General
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+q" = "exec ${terminal}";
        "${mod}+Ctrl+l" = "exec ${hyprlock}";
        "${mod}+Shift+e" = "exec ${logout}";
        "${mod}+Alt+e" = "exec ${fileManager}";
        "${mod}+Shift+c" = "reload";
        "${mod}+r" = "exec ${menu}";
        "Print" = "exec gradia --screenshot=INTERACTIVE";
        "${mod}+Shift+n" = "exec swaync-client -t -sw";
        "${mod}+Ctrl+b" = "exec 'pkill -USR1 .waybar-wrapped'";

        # Windows
        "${mod}+c" = "kill";
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";
        "${mod}+f" = "fullscreen toggle";

        # Layout
        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";
        "${mod}+a" = "focus parent";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        "${mod}+Shift+f" = "floating toggle";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";

        # Workspace navigation
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+m" = "workspace special:";
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+m" = "move container to workspace special:";

        # Scratchpad
        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";

        XF86AudioRaiseVolume = "exec swayosd-client --output-volume raise";
        XF86AudioLowerVolume  = "exec swayosd-client --output-volume lower";
        XF86AudioMute = "exec swayosd-client --output-volume mute-toggle";
        XF86AudioMicMute = "exec swayosd-client --input-volume mute-toggle";
        XF86MonBrightnessUp = "exec swayosd-client --brightness raise";
        XF86MonBrightnessDown = "exec swayosd-client --brightness lower";

        # Media control
        "XF86AudioPlay" = "exec ${playerctl} --ignore-player=firefox,chromium,brave play-pause";
        "XF86AudioNext" = "exec ${playerctl} --ignore-player=firefox,chromium,brave next";
        "XF86AudioPrev" = "exec ${playerctl} --ignore-player=firefox,chromium,brave previous";
      };

      bars = [
        { command = "${pkgs.waybar}/bin/waybar"; }
      ];

      # Appearance
      gaps = {
        inner = 2;
        outer = 2;
        bottom = 2;
        left = 2;
        right = 2;
      };

      window = {
        border = 2;
      };
      assigns = {
        "special:" = [
          { app_id = "^thunderbird$"; }
        ];
      };

      # ref:
      # https://github.com/jjquin/swayarch/blob/master/.config/sway/config.d/window_rules

      window.commands = [
        {
          command = "floating enable, resize set 70% 70%";
          criteria = {
            app_id = "^(gnome-disks|wihotspot|wihotspot-gui)$";
          };
        }
        {
          command = "floating enable, resize set 70% 70%";
          criteria = {
            app_id = "^[Rr]ofi$";
          };
        }
        {
          command = "floating enable, resize set 70% 70%";
          criteria = {
            app_id = "^(nm-applet|nm-connection-editor|blueman-manager)$";
          };
        }
        {
          command = "floating enable, move position center, resize set 70% 70%";
          criteria = {
            app_id = "^(pavucontrol|org.pulseaudio.pavucontrol)$";
          };
        }
        {
          command = "floating enable, resize set 70% 70%";
          criteria = {
            app_id = "^(nwg-look|qt5ct|qt6ct|[Yy]ad)$";
          };
        }
        {
          command = "floating enable, resize set 70% 70%";
          criteria = {
            app_id = "^xdg-desktop-portal-gtk$";
          };
        }
        {
          command = "floating enable, resize set 70% 70%";
          criteria = {
            app_id = "^.blueman-manager-wrapped$";
          };
        }
        {
          command = "floating enable, resize set 70% 70%";
          criteria = {
            app_id = "^nwg-displays$";
          };
        }
        {
          command = "floating enable";
          criteria = {
            app_id = "^[Ww]aypaper$";
          };
        }
        {
          command = "floating enable, floating_minimum_size 250 x 400";
          criteria = {
            class = "zoom";
          };
        }
        {
          command = "floating enable, resize set 1401 492, move position 6 40";
          criteria = {
            app_id = "^com.saivert.pwvucontrol$";
          };
        }
        {
          command = "floating enable, move position center, resize set 70% 70%";
          criteria = {
            app_id = "^firefox$";
            title = "^Picture-in-Picture$";
          };
        }
        {
          command = "inhibit_idle focus, floating enable, border none, fullscreen enable";
          criteria = {
            instance = "^(origin\.exe|gamescope)$";
          };
        }
        # {
        #   command = "inhibit_idle focus, border none, fullscreen enable, mark steam_game";
        #   criteria = {
        #     class = "^steam_app_.*$|^factorio$";
        #   };
        # }
        {
          command = "floating enable, max_render_time off; blur disabled";
          criteria = {
            instance = "^steamwebhelper$";
          };
        }
        {
          command = "floating enable, max_render_time off; blur disabled";
          criteria = {
            app_id = "^[Ll]utris$";
          };
        }
        {
          command = "floating enable, max_render_time off; blur disabled";
          criteria = {
            app_id = "^com.heroicgameslauncher.hgl$";
          };
        }
        {
          command = "floating disable, inhibit_idle none";
          criteria = {
            app_id = "^org\.telegram\.desktop$";
            title = "^Telegram$";
          };
        }
        {
          command = "floating enable, move position center";
          criteria = {
            title = "^Authentication Required$";
          };
        }
        {
          command = "floating enable";
          # command = "floating enable, resize set 1030 710";
          criteria = {
            title = "^(?:Open|Add|Open Folder|Save File|Save File as|Add Folder to Workspace)$";
          };
        }
        {
          command = "floating enable";
          criteria = {
            window_role = "pop-up";
          };
        }
        {
          command = "floating enable";
          criteria = {
            window_role = "bubble";
          };
        }
        {
          command = "floating enable";
          criteria = {
            window_role = "dialog";
          };
        }
        {
          command = "floating enable";
          criteria = {
            window_type = "dialog";
          };
        }
        {
          command = "inhibit_idle fullscreen";
          criteria = {
            class = "^.*$";
          };
        }
        {
          command = "inhibit_idle fullscreen";
          criteria = {
            app_id = "^.*$";
          };
        }
        {
          command = "floating enable";
          criteria = {
            app_id = "galculator";
          };
        }
        {
          command = "floating enable";
          criteria = {
            app_id = "be.alexandervanhee.gradia";
          };
        }
        {
          command = "title_format \"<span>[X] %title</span>\"";
          criteria = {
            shell = "xwayland";
          };
        }
        { command = "move container to workspace special:"; criteria = { app_id = "thunderbird"; }; }
        { command = "floating disable"; criteria = { app_id = "thunderbird"; }; }
        { command = "floating enable"; criteria = { app_id = "thunderbird"; title = ".*Compose.*"; }; }
        { command = "resize set width 800 height 600"; criteria = { app_id = "thunderbird"; title = ".*(Compose|Write\:).*"; }; }
        { command = "floating enable"; criteria = { app_id = "thunderbird"; title = ".*(Preferences|Settings|Address Book).*"; }; }
      ];

      # Input configuration
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_options = "ctrl:nocaps";
          repeat_delay = "200";
          repeat_rate = "50";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          scroll_factor = "0.5";
        };
      };
    };

    extraConfig = ''
      swaybg_command -
      focus_on_window_activation focus
      font pango:Berkeley Mono, Berkeley Mono Variable, monospace 10
    '';
  };
}
