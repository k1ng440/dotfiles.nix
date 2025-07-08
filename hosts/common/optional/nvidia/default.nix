{
  lib,
  config,
  pkgs,
  ...
}:
{
  nixpkgs.config.cudaSupport = true;
  services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

  environment.systemPackages = with pkgs; [
    vdpauinfo
    libva-utils
    nvtopPackages.nvidia
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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

  hardware.nvidia = {
    open = false;
    prime.sync.enable = lib.mkForce false;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = false;
  };

  environment = {
    etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool.json".source =
      ./50-limit-free-buffer-pool.json;
    variables = {
      __EGL_VENDOR_LIBRARY_FILENAMES = "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
      EGL_PLATFORM = "wayland";
      MOZ_DRM_DEVICE = "/dev/dri/renderD128";
    };
  };

  boot = {
    kernelParams = lib.mkMerge [
      [
        # NVreg_UsePageAttributeTable=1 (Default 0) - Activating the better
        # memory management method (PAT). The PAT method creates a partition type table
        # at a specific address mapped inside the register and utilizes the memory architecture
        # and instruction set more efficiently and faster.
        # If your system can support this feature, it should improve CPU performance.
        "nvidia.NVreg_UsePageAttributeTable=1"

        "nvidia_modeset.disable_vrr_memclk_switch=1" # stop really high memclk when vrr is in use.
      ]
      (lib.mkIf config.hardware.nvidia.powerManagement.enable [
        "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      ])
    ];
    blacklistedKernelModules = [ "nouveau" ];
  };
}
