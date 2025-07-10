{
  pkgs,
  lib,
  config,
  ...
}:
let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
in
with lib;
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
        modules-left = [
          "custom/startmenu"
          "wlr/taskbar"
          # "hyprland/window"
          "pulseaudio"
          "cpu"
          "memory"
          "idle_inhibitor"
        ];

        modules-center = [
          "hyprland/workspaces"
          "sway/workspaces"
        ];

        modules-right = [
          "mpris"
          "custom/hyprbindings"
          "custom/notification"
          "custom/exit"
          "battery"
          "tray"
          "clock"
        ];

        # https://github.com/Alexays/Waybar/wiki/Module:-Sway#workspaces
        "sway/workspaces" = {
          format = "{name}";
          on-scroll-up = "swaymsg workspace next";
          on-scroll-down = "swaymsg workspace prev";
          on-click = "activate";
          sort-by = "name";
        };

        # https://man.archlinux.org/man/extra/waybar/waybar-hyprland-workspaces.5.en
        "hyprland/workspaces" = {
          format = "{name}";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          on-click = "activate";
          sort-by = "name";
        };

        "wlr/taskbar" = {
          "format" = "{icon}";
          "icon-size" = 18;
          "tooltip-format" = "{title}";
          "on-click" = "activate";
          "on-click-middle" = "close";
          # "ignore-list" = ["Alacritty" "kitty"];
          "app_ids-mapping" = {
            "firefoxdeveloperedition" = "firefox-developer-edition";
          };
          "rewrite" = {
            "Firefox Web Browser" = "Firefox";
            "Foot Server" = "Terminal";
          };
        };
        "clock" = {
          format = '' {:L%I:%M %p}'';
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>/<tt><small>{calendar}</small></tt>";
          tooltip = true;
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
          tooltip = false;
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
          status-icons = {
            playing = "";
            paused = "";
          };
        };
        "custom/exit" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && wlogout";
        };
        "custom/startmenu" = {
          tooltip = false;
          format = "  ";
          on-click = "sleep 0.1 && rofi-launcher";
          # on-click = "sleep 0.1 && nwg-drawer -mb 200 -mt 200 -mr 200 -ml 200";
        };
        "custom/hyprbindings" = {
          tooltip = false;
          format = "󱕴";
          on-click = "sleep 0.1 && list-keybinds";
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
      }
    ];
    style = concatStrings [
      ''
        * {
          font-family: "JetBrainsMonoNL Nerd Font Propo";
          font-size: 18px;
          border-radius: 0px;
          border: none;
          min-height: 0px;
        }
        window#waybar {
          background: rgba(0,0,0,0);
        }
        #workspaces {
          color: #${config.lib.stylix.colors.base00};
          background: #${config.lib.stylix.colors.base01};
          margin: 4px 4px;
          padding: 5px 5px;
          border-radius: 16px;
        }
        #workspaces button {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          opacity: 0.5;
          transition: ${betterTransition};
        }
        #workspaces button.active {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          transition: ${betterTransition};
          opacity: 1.0;
          min-width: 40px;
        }
        #workspaces button:hover {
          font-weight: bold;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          opacity: 0.8;
          transition: ${betterTransition};
        }
        tooltip {
          background: #${config.lib.stylix.colors.base00};
          border: 1px solid #${config.lib.stylix.colors.base08};
          border-radius: 12px;
        }
        tooltip label {
          color: #${config.lib.stylix.colors.base08};
        }
        #window, #pulseaudio, #cpu, #memory, #idle_inhibitor, #taskbar {
          font-weight: bold;
          margin: 4px 0px;
          margin-left: 7px;
          padding: 0px 18px;
          background: #${config.lib.stylix.colors.base00};
          color: #${config.lib.stylix.colors.base08};
          border-radius: 8px 8px 8px 8px;
        }
        #idle_inhibitor {
          font-size: 28px;
        }
        #custom-startmenu {
          color: #${config.lib.stylix.colors.base0B};
          background: #${config.lib.stylix.colors.base02};
          font-size: 22px;
          margin: 0px;
          padding: 0px 5px 0px 5px;
          border-radius: 16px 16px 16px 16px;
        }
        #custom-hyprbindings, #network, #battery,
        #custom-notification, #tray, #custom-exit, #mpris {
          /* font-weight: bold; */
          font-size: 20px;
          background: #${config.lib.stylix.colors.base00};
          color: #${config.lib.stylix.colors.base08};
          margin: 4px 0px;
          margin-right: 7px;
          border-radius: 8px 8px 8px 8px;
          padding: 0px 18px;
        }
        #clock {
          font-weight: bold;
          font-size: 16px;
          color: #0D0E15;
          background: linear-gradient(90deg, #${config.lib.stylix.colors.base0B}, #${config.lib.stylix.colors.base02});
          margin: 0px;
          padding: 0px 5px 0px 5px;
          border-radius: 16px 16px 16px 16px;
        }
        #taskbar button {
            margin: 0;
            border-radius: 5px 5px 5px 5px;
            padding: 0px 5px 0px 5px;
        }
        #taskbar.empty {
            background:transparent;
            border: 0;
            padding: 0;
            margin: 0;
        }
      ''
    ];
  };
}
