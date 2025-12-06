{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

  environment.systemPackages = with pkgs; [
    vdpauinfo
    libva-utils
    nvtopPackages.nvidia
  ];

  hardware = {
    nvidia = {
      open = true;
      gsp.enable = config.hardware.nvidia.open;
      nvidiaSettings = true;
      prime.sync.enable = lib.mkForce false;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      videoAcceleration = true;
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "590.44.01";
        sha256_64bit = "sha256-VbkVaKwElaazojfxkHnz/nN/5olk13ezkw/EQjhKPms=";
        openSha256 = "sha256-ft8FEnBotC9Bl+o4vQA1rWFuRe7gviD/j1B8t0MRL/o=";
        settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
        persistencedSha256 = lib.fakeSha256;
      };
    };
    nvidia-container-toolkit = {
      enable = true;
      package = pkgs.nvidia-container-toolkit;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver # VAAPI
      ];
    };
  };

  environment = {
    sessionVariables = {
      # fix hw acceleration and native wayland on losslesscut
      __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
      CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
      # disable vsync
      __GL_SYNC_TO_VBLANK = "0";
      # enable gsync / vrr support
      __GL_VRR_ALLOWED = "1";
      # lowest frame buffering -> lower latency
      __GL_MaxFramesAllowed = "1";

      GBM_BACKEND = "nvidia-drm";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
      EGL_PLATFORM = "wayland";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      MOZ_DRM_DEVICE = "/dev/dri/renderD128";
    };
    # fix high vram usage on discord and hyprland. match with the wrapper procnames
    etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool.json".text =
      builtins.toJSON
        {
          rules =
            map
              (proc: {
                pattern = {
                  feature = "procname";
                  matches = proc;
                };
                profile = "No VidMem Reuse";
              })
              [
                "Hyprland"
                ".Hyprland-wrapped"
                "Discord"
                ".Discord-wrapped"
                "DiscordCanary"
                ".DiscordCanary-wrapped"
                "electron"
                ".electron-wrapped"
                "librewolf"
                ".librewolf-wrapped"
                ".librewolf-wrapped_"
                "losslesscut"
              ];
        };
  };

  systemd = {
    # makes kexec work with nvidia GPUs.
    services.nvidia-kexec = {
      unitConfig = {
        Description = "Unload Nvidia before kexec";
        Documentation = "man:modprobe(8)";
        DefaultDependencies = "no";
        After = "umount.target";
        Before = "kexec.target";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe' pkgs.kmod "modprobe"} -r nvidia_drm";
      };
      wantedBy = [ "kexec.target" ];
    };
  };

  boot = {
    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
      "nvidia_uvm"
    ];

    kernelParams = lib.mkMerge [
      [
        "nvidia.NVreg_UsePageAttributeTable=1"
        "nvidia_modeset.disable_vrr_memclk_switch=1" # stop really high memclk when vrr is in use.
        "nvidia.NVreg_EnableResizableBar=1" # enable reBAR
        "nvidia.NVreg_RegistryDwords=RmEnableAggressiveVblank=1" # low-latency stuff
        "mem_sleep_default=s2idle"
        "nvidia.NVreg_EnableS0ixPowerManagement=1"
        "nvidia.NVreg_S0ixPowerManagementVideoMemoryThreshold=512"
      ]
      (lib.mkIf config.hardware.nvidia.powerManagement.enable [
        "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      ])
    ];
    blacklistedKernelModules = [ "nouveau" ];
  };
}
