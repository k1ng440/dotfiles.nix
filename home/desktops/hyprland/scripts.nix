{
  lib,
  config,
  pkgs,
  ...
}:
let
  # Monitor Toggling
  primaryMonitor = lib.head (lib.filter (m: m.primary) config.monitors);

  # Toggle all monitors
  toggleMonitors = pkgs.writeShellApplication {
    name = "toggleMonitors";
    text = ''
      #!/bin/bash

      get_all_monitors() {
        hyprctl monitors -j | jq -r '.[].name'
      }

      all_monitors_on() {
        for monitor in $(get_all_monitors); do
          state=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .dpmsStatus")
          if [ "$state" != "true" ]; then
            return 1
          fi
        done
        return 0
      }

      if all_monitors_on; then
        for monitor in $(get_all_monitors); do
          hyprctl dispatch dpms standby "$monitor"
        done
        echo "All monitors are now in standby mode."
      else
        for monitor in $(get_all_monitors); do
          hyprctl dispatch dpms on "$monitor"
        done
        echo "All monitors are now on."
      fi
    '';
  };

  # Toggle all non-primary monitors
  # dpms standby seems to be working but if monitor wakeup is too sensitive for gaming, can try suspend or off instead
  toggleMonitorsNonPrimary = pkgs.writeShellApplication {
    name = "toggleMonitorsNonPrimary";
    text = ''
      #!/bin/bash

      PRIMARY_MONITOR="${primaryMonitor.name}"
      get_all_monitors() {
        hyprctl monitors -j | jq -r '.[].name'
      }

      all_monitors_on() {
        for monitor in $(get_all_monitors); do
          state=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .dpmsStatus")
          if [ "$state" != "true" ]; then
            return 1
          fi
        done
        return 0
      }

      if all_monitors_on; then
        for monitor in $(get_all_monitors); do
          if [ "$monitor" != "$PRIMARY_MONITOR" ]; then
            hyprctl dispatch dpms standby "$monitor"
          fi
        done
        echo "All monitors except $PRIMARY_MONITOR are now in standby mode."
      else
        for monitor in $(get_all_monitors); do
          hyprctl dispatch dpms on "$monitor"
        done
        echo "All monitors are now on."
      fi
    '';
  };
in
{
  home.packages = [
    toggleMonitors
    toggleMonitorsNonPrimary
  ];
}
