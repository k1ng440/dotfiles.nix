{ hostname, ... }:
{
  services.xserver = {
    enable = false;
    videoDrivers = ["nvidia"];
    # displayManager.gdm = {
    #   enable = false;
    #   wayland = false;
    # };
  };
}
