{ machine, ... }:
{
  services.swayosd.enable =
    !machine.computed.isFullDE && !machine.windowManager.hyprland.noctalia.enable;
}
