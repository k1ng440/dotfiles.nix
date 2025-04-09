{ lib, pkgs, config, ... }:
let
  cfg = config.drivers.nvidia;
in {
  options.drivers.nvidia = {
    enable = lib.mkEnableOption "Enable Nvidia Drivers";
    open = lib.mkOption {
      description = "Enable Open Nvidia Drivers";
      type = lib.types.bool;
      default = true;
      example = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      prime.sync.enable = lib.mkForce false;
      open = cfg.open;
    };
  };
}

