{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (lib.elem "nvidia-gpu" config.machine.capabilities) {
    services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

    environment.systemPackages = with pkgs; [
      vdpauinfo
      libva-utils
      nvtopPackages.nvidia
    ];

    hardware = {
      nvidia = {
        open = false;
        gsp.enable = config.hardware.nvidia.open;
        nvidiaSettings = true;
        prime.sync.enable = lib.mkForce false;
        modesetting.enable = true;
        powerManagement.enable = true;
        videoAcceleration = true;
      };
      nvidia-container-toolkit = {
        enable = true;
        package = pkgs.nvidia-container-toolkit;
      };
      graphics = {
        extraPackages = with pkgs; [
          nvidia-vaapi-driver # VAAPI
        ];
      };
    };

    environment = {
      sessionVariables = {
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
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
        EGL_PLATFORM = "wayland";
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_DRM_DEVICE = "/dev/dri/by-path/pci-0000:0b:00.0-render";
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
                  "firefox"
                  ".firefox-wrapped"
                  "losslesscut"
                ];
          };
    };

    systemd.services = {
      hyprland-suspend = lib.mkIf config.machine.windowManager.hyprland.enable {
        description = "Suspend Hyprland";
        before = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "systemd-hybrid-sleep.service"
          "nvidia-suspend.service"
          "nvidia-hibernate.service"
        ];
        wantedBy = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
          "systemd-suspend.service"
          "systemd-hibernate.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.procps}/bin/pkill -f -STOP Hyprland";
        };
      };

      hyprland-resume = lib.mkIf config.machine.windowManager.hyprland.enable {
        description = "Resume Hyprland";
        after = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "systemd-hybrid-sleep.service"
          "nvidia-resume.service"
        ];
        wantedBy = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
          "systemd-suspend.service"
          "systemd-hibernate.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = [
            "${pkgs.procps}/bin/pkill -f -CONT Hyprland"
            "${pkgs.coreutils}/bin/sleep 2"
            "${pkgs.sudo}/bin/sudo -u ${config.machine.username} env XDG_RUNTIME_DIR=/run/user/${toString config.machine.userUid} ${pkgs.hyprland}/bin/hyprctl dispatch dpms on"
          ];
        };
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
          "nvidia-drm.modeset=1"
          "nvidia-drm.fbdev=1"
        ]
        (lib.mkIf config.hardware.nvidia.powerManagement.enable [
          "nvidia.NVreg_TemporaryFilePath=/var/tmp"
        ])
      ];
      blacklistedKernelModules = [ "nouveau" ];
    };
  };
}
