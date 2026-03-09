{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-center = [ "hyprland/workspaces" ];
        modules-left = [
          "custom/startmenu"
          "custom/arrow6"
          "pulseaudio"
          "cpu"
          "memory"
          "idle_inhibitor"
          "custom/arrow7"
          "hyprland/window"
        ];
        modules-right = [
          "custom/arrow4"
          "custom/hyprbindings"
          "custom/arrow3"
          "custom/notification"
          "custom/arrow3"
          "custom/exit"
          "battery"
          "custom/arrow2"
          "tray"
          "custom/arrow1"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            default = " ";
            active = " ";
            urgent = " ";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };
        "clock" = {
          format = " {:L%I:%M %p}";
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
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
          format-disconnected = "󰤮 ";
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
            headphone = " ";
            hands-free = " ";
            headset = " ";
            phone = " ";
            portable = " ";
            car = " ";
            default = [
              " "
              " "
              " "
            ];
          };
          on-click = "sleep 0.1 && pwvucontrol-toggle";
        };
        "custom/exit" = {
          tooltip = false;
          format = " ";
          on-click = "sleep 0.1 && wlogout";
        };
        "custom/startmenu" = {
          tooltip = false;
          format = " ";
          on-click = "sleep 0.1 && rofi-launcher";
        };
        "custom/hyprbindings" = {
          tooltip = false;
          format = "󱕴 ";
          on-click = "sleep 0.1 && list-keybinds";
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = " ";
            deactivated = " ";
          };
          tooltip = "true";
        };
        "custom/notification" = {
          tooltip = false;
          format = "{icon} {}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = " ";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = " ";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = " ";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = " ";
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
            "󰁺 "
            "󰁻 "
            "󰁼 "
            "󰁽 "
            "󰁾 "
            "󰁿 "
            "󰂀 "
            "󰂁 "
            "󰂂 "
            "󰁹 "
          ];
          on-click = "";
          tooltip = false;
        };
        "custom/arrow1" = {
          format = "";
        };
        "custom/arrow2" = {
          format = "";
        };
        "custom/arrow3" = {
          format = "";
        };
        "custom/arrow4" = {
          format = "";
        };
        "custom/arrow5" = {
          format = "";
        };
        "custom/arrow6" = {
          format = "";
        };
        "custom/arrow7" = {
          format = "";
        };
      }
    ];
    style = lib.concatStrings [
      ''
        * {
          font-family: "JetBrainsMonoNL Nerd Font Propo";
          font-size: 16px;
          border-radius: 0px;
          border: none;
          min-height: 0px;
        }
        window#waybar {
          background: #1d2021;
          color: #d5c4a1;
        }
        #workspaces button {
          padding: 0px 5px;
          background: transparent;
          color: #bdae93; /* #d5c4a1 */
        }
        #workspaces button.active {
          color: #d5c4a1; /* #fbf1c7 for better contrast */
          background: #504945; /* #3c3836 for subtle bg */
        }
        #workspaces button:hover {
          color: #fb4934; /* #fb4934 */
          background: #3c3836; /* #32302f for hover bg */
        }
        tooltip {
          background: #1d2021;
          border: 1px solid #d5c4a1;
          border-radius: 12px;
        }
        tooltip label {
          color: #d5c4a1;
        }
        #window {
          padding: 0px 10px;
        }
        #pulseaudio, #cpu, #memory, #idle_inhibitor {
          padding: 0px 10px;
          background: #bdae93;
          color: #1d2021;
        }
        #custom-startmenu {
          color: #504945;
          padding: 0px 14px;
          font-size: 20px;
          background: #b8bb26;
        }
        #custom-hyprbindings, #network, #battery,
        #custom-notification, #custom-exit {
          background: #d65d0e;
          color: #1d2021;
          padding: 0px 10px;
        }
        #tray {
          background: #504945;
          color: #1d2021;
          padding: 0px 10px;
        }
        #clock {
          font-weight: bold;
          padding: 0px 10px;
          color: #1d2021;
          background: #d3869b;
        }
        #custom-arrow1 {
          font-size: 24px;
          color: #d3869b;
          background: #504945;
        }
        #custom-arrow2 {
          font-size: 24px;
          color: #504945;
          background: #d65d0e;
        }
        #custom-arrow3 {
          font-size: 24px;
          color: #1d2021;
          background: #d65d0e;
        }
        #custom-arrow4 {
          font-size: 22px;
          color: #d65d0e;
          background: transparent;
        }
        #custom-arrow6 {
          font-size: 24px;
          color: #b8bb26;
          background: #bdae93;
        }
        #custom-arrow7 {
          font-size: 24px;
          color: #bdae93;
          background: transparent;
        }
      ''
    ];
  };
}
