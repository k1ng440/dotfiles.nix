{ lib, pkgs, config, ... }:
let
  cfg = config.vm.guest-services;
in {
  options.vm.guest-services = {
    enable = lib.mkEnableOption "Enable Virtual Machine Guest Services";
  };

  config = lib.mkIf cfg.enable {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
    services.spice-webdavd.enable = true;
  };
}

