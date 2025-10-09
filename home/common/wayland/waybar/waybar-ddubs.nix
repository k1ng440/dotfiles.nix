{
  pkgs,
  lib,
  config,
  ...
}:
let
  warpStatusScript = import ./warp-status-script.nix { inherit pkgs; };
  logout = lib.getExe' pkgs.nwg-bar "nwg-bar";
in
{
  # Configure & Theme Waybar
  # https://github-wiki-see.page/m/Alexays/Waybar/wiki/Module%3A-Hyprland
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        position = "top";
        ipc = true;
        modules-left = [
          "custom/startmenu"
          "wlr/taskbar"
          "pulseaudio"
          "cpu"
          "memory"
          "idle_inhibitor"
          "hyprland/window"
          "sway/window"
        ];

        modules-center = [
          "hyprland/workspaces"
          "sway/workspaces"
        ];

        modules-right = [
          "mpris"
          "custom/notification"
          "battery"
          "tray"
          "custom/cloudflare-warp"
          "clock"
          "systemd-failed-units"
          "custom/exit"
        ];

        # https://github.com/Alexays/Waybar/wiki/Module:-Sway#workspaces
        "sway/workspaces" = {
          format = "{name}";
          on-scroll-up = "swaymsg workspace next";
          on-scroll-down = "swaymsg workspace prev";
          on-click = "activate";
          sort-by = "name";

          persistent-workspaces =
            let
              workspaceMonitorPairs = lib.concatMap (
                m:
                map (w: {
                  name = w.name;
                  monitor = m.name;
                }) m.workspaces
              ) config.monitors;

              groupedWorkspaces = lib.groupBy (pair: pair.name) workspaceMonitorPairs;
            in
            lib.mapAttrs (workspaceName: pairs: map (pair: pair.monitor) pairs) groupedWorkspaces;
        };

        "sway/window" = {
          offscreen-css-text = "(inactive)";
          rewrite = {
            "(.*) - vim" = " $1";
            "(.*) - Nvim" = " $1";
            "(.*) - Mozilla Firefox" = " $1";
            "(.*) - fish" = "> [$1]";
          };
        };

        # https://man.archlinux.org/man/extra/waybar/waybar-hyprland-workspaces.5.en
        "hyprland/workspaces" = {
          format = "{name}";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          on-click = "activate";
          sort-by = "name";
          # persistent-workspaces =
          #   let
          #     workspaceMonitorPairs = lib.concatMap (
          #       m:
          #       map (w: {
          #         name = w.name;
          #         monitor = m.name;
          #       }) m.workspaces
          #     ) config.monitors;
          #
          #     groupedWorkspaces = lib.groupBy (pair: pair.name) workspaceMonitorPairs;
          #   in
          #     lib.mapAttrs (workspaceName: pairs: map (pair: pair.monitor) pairs) groupedWorkspaces;
        };

        "custom/cloudflare-warp" = {
          format = "{text}";
          interval = 10;
          return-type = "json";
          exec = "${warpStatusScript}/bin/waybar-warp-status";
          on-click = "warp-cli connect";
          on-click-right = "warp-cli disconnect";
          tooltip = true;
          tooltip-format = "Left click: Connect\nRight click: Disconnect";
        };

        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 18;
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-middle = "close";
          app_ids-mapping = {
            "firefoxdeveloperedition" = "firefox-developer-edition";
          };
          rewrite = {
            "Firefox Web Browser" = "Firefox";
            "Foot Server" = "Terminal";
          };
        };
        "clock" = {
          format = '' {:L%I:%M %p}'';
          tooltip-format = "<small>{calendar}</small>";
          tooltip = true;
          calendar = {
            format = {
              # months =    "<span color='#ffead3'><b>{}</b></span>";
              # days =      "<span color='#ecc6d9'><b>{}</b></span>";
              # weeks =     "<span color='#99ffdd'><b>W{}</b></span>";
              # weekdays =  "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#${config.lib.stylix.colors.base08}'><b>{}</b></span>";
            };
          };
        };
        "hyprland/window" = {
          max-length = 22;
          separate-outputs = false;
          rewrite = {
            "" = " 🙈 No Windows? ";
          };
        };
        "memory" = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };
        "cpu" = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };
        "disk" = {
          format = " {free}";
          tooltip = true;
        };
        "network" = {
          tooltip = false;
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = " {bandwidthDownOctets}";
          format-wifi = "{icon} {signalStrength}%";
          format-disconnected = "󰤮";
        };
        "tray" = {
          spacing = 12;
        };
        "pulseaudio" = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "sleep 0.1 && pwvucontrol-toggle";
        };
        mpris = {
          format = "{status_icon} {artist} - {title}";
          title-len = 40;
          ignored-players = [ "firefox" ];
          interval = "4";
          status-icons = {
            playing = "";
            paused = "";
          };
        };
        "custom/exit" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && ${logout}";
        };
        "custom/startmenu" = {
          tooltip = false;
          format = "  ";
          on-click = "sleep 0.1 && rofi-launcher";
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = "true";
        };
        "custom/notification" = {
          tooltip = false;
          format = "{icon} {}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && task-waybar";
          escape = true;
        };
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          on-click = "";
          tooltip = false;
        };
        systemd-failed-units = {
          "hide-on-ok" = true;
          "format" = "✗ {nr_failed}";
          "format-ok" = "✓";
          "system" = true;
          "user" = true;
        };
      }
    ];
    style =
      let
        background = "#${config.lib.stylix.colors.base00}";
        foreground = "#${config.lib.stylix.colors.base05}";
        active-background = background;
        active-foreground = "#${config.lib.stylix.colors.base08}";

        # Additional variables for borders and styling
        border-color = "#${config.lib.stylix.colors.base02}";
        workspace-background = "#${config.lib.stylix.colors.base01}";
        muted-color = "#${config.lib.stylix.colors.base03}";
        highlight-color = "#${config.lib.stylix.colors.base05}";
        shadow-color = "#${config.lib.stylix.colors.base03}";
        accent-color = "#${config.lib.stylix.colors.base0B}";
      in
      lib.concatStrings [
        ''
          * {
            font-family: "Berkeley Mono", "Berkeley Mono Variable", "Symbols Nerd Font", monospace;
            font-size: 14px;
            border-radius: 0px;
            border: none;
            min-height: 0px;
          }

          window#waybar {
            background: rgba(0,0,0,0);
          }

          /* Workspaces styling */
          #workspaces {
            background: ${workspace-background};
            margin: 4px 4px;
            padding: 5px 5px;
            border-radius: 12px;
            border: 1px solid ${border-color};
          }

          #workspaces button {
            padding: 0px 8px;
            border-radius: 12px;
            color: ${foreground};
            background-color: transparent;
            text-shadow: 0px 0px 2px ${background};
            transition: all 0.2s ease;
            margin: 0 2px;
          }

          #workspaces button.persistent {
            color: ${muted-color};
          }
          #workspaces button.empty {
            opacity: 0.5;
          }

          #workspaces button.active,
          #workspaces button.focused {
            color: ${active-foreground};
            background-color: ${border-color};
            border-radius: 12px;
            box-shadow: 0 0 4px ${shadow-color};
          }

          #workspaces button.urgent {
            color: ${active-foreground};
          }

          #workspaces button:hover {
            color: ${highlight-color};
            background-color: ${border-color};
          }

          #window, #pulseaudio, #cpu, #memory, #taskbar, #idle_inhibitor,
          #network, #battery, #custom-notification, #tray, #custom-exit,
          #mpris, #clock, #window, #pulseaudio, #cpu, memory, #taskbar,
          #idle_inhibitor, #custom-startmenu, #systemd-failed-units,
          #custom-cloudflare-warp
          {
            margin: 4px 0 4px 7px;
            font-weight: bold;
            color: ${foreground};
            background: ${background};
            border-radius: 6px;
            padding: 2px 8px 2px 8px;
          }

          window#waybar.empty {
            background-color: transparent;
          }

          #idle_inhibitor.deactivated {
            color: ${foreground};
            font-size: 18px;
          }

          #idle_inhibitor.activated {
            color: ${active-foreground};
            font-size: 18px;
          }

          #custom-startmenu {
            color: ${accent-color};
            background: ${border-color};
            font-size: 20px;
            margin-left: 10px;
          }

          #custom-exit {
            color: ${accent-color};
            background: ${border-color};
            margin-right: 10px;
          }

          #systemd-failed-units {
            background-color: ${active-background};
            color: ${active-foreground};
          }

          #custom-cloudflare-warp.connected {
              background-color: ${active-background};
              color: ${active-foreground};
          }

          /* Taskbar button styling */
          #taskbar button {
            background: ${background};
            border: 0;
            padding: 2px 1px 0 0;
            margin: 0;
            border-radius: 5px;
          }

          #taskbar.empty {
            background: transparent;
            border: 0;
            padding: 0;
            margin: 0;
          }

          /* Tooltip styling */
          tooltip {
            background: ${background};
            border: 1px solid ${workspace-background};
            border-radius: 12px;
          }

          tooltip label {
            color: ${foreground};
          }
        ''
      ];
  };
}
