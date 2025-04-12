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
      powerManagement.enable = false;
      nvidiaSettings = true;
    };

    environment.variables = {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      MOZ_ENABLE_WAYLAND = "1";
      NVD_BACKEND = "direct";
    };

    programs.firefox.preferences = {

      "media.ffmpeg.vaapi.enabled" = true;
      "media.rdd-ffmpeg.enabled" = true;
      "media.av1.enabled" = true;
      "gfx.x11-egl.force-enabled" = true;
      "widget.dmabuf.force-enabled" = true;
    };
  };
}
