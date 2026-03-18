{ machine, ... }:
{
  services.swayosd.enable = !machine.windowManager.hyprland.noctalia.enable;
}
