{ config, lib, ... }:
{
  config = lib.mkIf config.machine.services.kdeconnect {
    programs.kdeconnect.enable = true;
  };
}
