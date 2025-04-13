{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.nixconfig.drivers.nvidia;
in
{
  options.nixconfig.drivers.nvidia = {
    enable = lib.mkEnableOption "Enable Nvidia Drivers";
    open = lib.mkOption {
      description = "Enable Open Nvidia Drivers";
      type = lib.types.bool;
      default = true;
      example = true;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vdpauinfo # sudo vainfo
      libva-utils # sudo vainfo
    ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver # VAAPI
      ];
    };

    boot.initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
      "nvidia_uvm"
    ];

    services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
    hardware.nvidia = {
      prime.sync.enable = lib.mkForce false;
      open = cfg.open;
      modesetting.enable = true;
      powerManagement.enable = true;
      nvidiaSettings = true;
    };

    environment.variables = {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };

    # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/472
    boot.kernelParams = lib.mkIf cfg.open [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "quiet" ];
  };
}
