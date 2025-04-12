{...}: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      /*
      - Lock screen after 5 minutes without turning off the screen.
      - Turn off the screen after 7 minutes and turn on when activity is detected.
      - Suspend the system after 10 minutes to save power.
      */

      listener = [
        # Lock the screen
        {
          timeout = "300";
          on-timeout = "loginctl lock-session";
        }
        # Turn off screen
        {
          timeout = 420;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
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
