{
  lib,
  pkgs,
  ...
}:
{
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
    open = true;
    prime.sync.enable = lib.mkForce false;
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
}
