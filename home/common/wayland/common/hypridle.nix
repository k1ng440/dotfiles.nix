{ pkgs, ... }:
let
  dpmsScript = pkgs.writeShellScript "dpms-control" ''
    if pgrep -x "Hyprland" > /dev/null; then
      if [ "$1" = "off" ]; then
        hyprctl dispatch dpms off
      else
        hyprctl dispatch dpms on
      fi
    elif pgrep -x "sway" > /dev/null; then
      if [ "$1" = "off" ]; then
        swaymsg 'output * dpms off'
      else
        swaymsg 'output * dpms on'
      fi
    else
      # Fallback to wlopm
      if [ "$1" = "off" ]; then
        wlopm --off '*'
      else
        wlopm --on '*'
      fi
    fi
  '';
  lockScript = pkgs.writeShellScript "lock-screen" ''
    if pgrep -x "Hyprland" > /dev/null; then
      loginctl lock-session
    elif pgrep -x "sway" > /dev/null; then
      hyprlock
    else
      hyprlock
    fi
  '';
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${lockScript}";
        before_sleep_cmd = "${lockScript}";
        after_sleep_cmd = "${dpmsScript} on";
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
      };

      /*
        - Lock screen after 5 minutes without turning off the screen.
        - Turn off the screen after 7 minutes and turn on when activity is detected.
        - Suspend the system after 10 minutes to save power.
      */

      listener = [
        # Lock the screen
        {
          timeout = 300;
          on-timeout = "${lockScript}";
        }
        # Turn off screen
        {
          timeout = 420;
          on-timeout = "${dpmsScript} off";
          on-resume = "${dpmsScript} on";
        }
        # Suspend the system
        {
          timeout = 600;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
