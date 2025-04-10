{ lib, pkgs, config, ... }:
let
  cfg = config.nixconfig.vm.guest-services;
in {
  options.nixconfig.vm.guest-services = {
    enable = lib.mkEnableOption "Enable Virtual Machine Guest Services";
  };

  config = lib.mkIf cfg.enable {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
    services.spice-webdavd.enable = true;
  };
}

