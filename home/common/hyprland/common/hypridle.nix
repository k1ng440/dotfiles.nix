{
  pkgs,
  machine,
  ...
}:
let
  dpmsScript = pkgs.writeShellScript "dpms-control" ''
    if pgrep -x "Hyprland" > /dev/null; then
      if [ "$1" = "off" ]; then
        ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
      else
        ${pkgs.procps}/bin/pkill -f -CONT Hyprland || true
        ${pkgs.hyprland}/bin/hyprctl dispatch dpms on || true
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

  lockCmd =
    if machine.windowManager.hyprland.noctalia.enable then
      "noctalia-shell ipc call lockScreen lock"
    else
      "${pkgs.hyprlock}/bin/hyprlock";
in
{
  services.hypridle = {
    inherit (machine.windowManager.hyprland) enable;
    settings = {
      general = {
        lock_cmd = lockCmd;
        before_sleep_cmd = lockCmd;
        after_sleep_cmd = "${dpmsScript} on";
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
      };

      /*
        - Lock screen after 5 minutes without turning off the screen.
        - Turn off the screen after 10 minutes and turn on when activity is detected.
        - Suspend the system after 20 minutes to save power.
      */

      listener = [
        # Lock the screen
        {
          timeout = 300;
          on-timeout = lockCmd;
        }
        # Turn off screen
        {
          timeout = 600;
          on-timeout = "${dpmsScript} off";
          on-resume = "${dpmsScript} on";
        }
        # Suspend the system
        {
          timeout = 1200;
          on-timeout = "systemctl suspend";
          on-resume = "${dpmsScript} on";
        }
      ];
    };
  };
}
