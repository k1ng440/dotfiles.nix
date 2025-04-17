{ config, ... }:
{
  services.syncthing = {
    enable = true;
    user = "${config.hostSpec.username}";
    dataDir = "/home/${config.hostSpec.username}";
    configDir = "/home/${config.hostSpec.username}/.config/syncthing";
  };
}
