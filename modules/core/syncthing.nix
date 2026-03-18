{ config, lib, ... }:
{
  config = lib.mkIf config.machine.services.syncthing {
    services.syncthing = {
      enable = true;
      user = "${config.machine.username}";
      dataDir = "${config.machine.home}";
      configDir = "${config.machine.home}/.config/syncthing";
    };
  };
}
