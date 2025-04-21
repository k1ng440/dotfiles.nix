{
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    vdpauinfo
    libva-utils
    nvtopPackages.nvidia
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
    EGL_PLATFORM = "wayland";
    MOZ_DRM_DEVICE = "/dev/dri/renderD128";
  };

  # Hack for memory leak fix.
  # https://github.com/NVIDIA/egl-wayland/issues/126#issuecomment-2379945259
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.txt".text =
    ''
      {
        "pattern": {
          "feature": "procname",
          "matches": "Hyprland"
        },
        "profile": "Limit Free Buffer Pool On Wayland Compositors"
      },
      {
        "pattern": {
          "feature": "procname",
          "matches": "gnome-shell"
        },
        "profile": "Limit Free Buffer Pool On Wayland Compositors"
      }
    '';
}
