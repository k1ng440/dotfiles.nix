{ machine, ... }:
{
  services.swayosd.enable = !machine.computed.isFullDE;
}
