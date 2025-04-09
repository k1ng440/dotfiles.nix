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
    boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];
    services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
    hardware.nvidia = {
      prime.sync.enable = lib.mkForce false;
      open = cfg.open;
      modesetting.enable = true;
      powerManagement.enable = false;
      nvidiaSettings = true;
    };
  };
}

