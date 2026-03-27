{
  flake.modules.nixos.hardware_nvidiagpu =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "nvidia-x11"
        ];

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
          nvidiaSettings = false; # gui app
          prime.sync.enable = lib.mkDefault false;
          modesetting.enable = true;
          powerManagement.enable = true;
          videoAcceleration = true;
          package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
            version = "595.45.04";
            sha256_64bit = "sha256-zUllSSRsuio7dSkcbBTuxF+dN12d6jEPE0WgGvVOj14=";
            openSha256 = "sha256-uqNfImwTKhK8gncUdP1TPp0D6Gog4MSeIJMZQiJWDoE=";
            settingsSha256 = "sha256-Y45pryyM+6ZTJyRaRF3LMKaiIWxB5gF5gGEEcQVr9nA=";
            persistencedSha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
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
          CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
          __GL_SYNC_TO_VBLANK = "0";
          __GL_VRR_ALLOWED = "1";
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
                    "vesktop"
                    ".Vesktop-wrapped"
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
                    "niri"
                    ".Niri-wrapped"
                  ];
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
