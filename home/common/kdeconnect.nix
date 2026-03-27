{ machine, ... }:
{
  services.kdeconnect = {
    enable = machine.services.kdeconnect;
    indicator = machine.windowManager.hyprland.enable || machine.windowManager.niri.enable;
  };
}
