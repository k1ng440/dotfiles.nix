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
          open = false;
          gsp.enable = config.hardware.nvidia.open;
          nvidiaSettings = false; # gui app
          prime.sync.enable = lib.mkDefault false;
          modesetting.enable = true;
          powerManagement.enable = true;
          videoAcceleration = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
          #   version = "595.58.03";
          #   sha256_64bit = "sha256-jA1Plnt5MsSrVxQnKu6BAzkrCnAskq+lVRdtNiBYKfk=";
          #   openSha256 = "sha256-uqNfImwTKhK8gncUdP1TPp0D6Gog4MSeIJMZQiJWDoE=";
          #   settingsSha256 = "sha256-Y45pryyM+6ZTJyRaRF3LMKaiIWxB5gF5gGEEcQVr9nA=";
          #   persistencedSha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          # };
        };
        nvidia-container-toolkit = {
          enable = true;
          package = pkgs.nvidia-container-toolkit;
        };
        graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [
            nvidia-vaapi-driver
            libvdpau-va-gl
            libva-vdpau-driver
            vulkan-loader
          ];
          extraPackages32 = with pkgs; [
            vulkan-loader
          ];
        };
      };

      environment = {
        sessionVariables = {
          CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";

          # OpenGL / low-latency
          __GL_SYNC_TO_VBLANK = "0";
          __GL_VRR_ALLOWED = "1";
          __GL_MaxFramesAllowed = "1";

          # Wayland / EGL
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          EGL_PLATFORM = "wayland";

          # VA-API / video acceleration
          LIBVA_DRIVER_NAME = "nvidia";
          NVD_BACKEND = "direct";
          VDPAU_DRIVER = "nvidia";

          # Firefox
          MOZ_ENABLE_WAYLAND = "1";
          MOZ_DISABLE_RDD_SANDBOX = "1";
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
                    "quickshell"
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
            "nvidia_modeset.disable_vrr_memclk_switch=1"
            "nvidia.NVreg_EnableResizableBar=1"
            "nvidia.NVreg_RegistryDwords=RmEnableAggressiveVblank=1"
            "nvidia-drm.modeset=1"
            "nvidia-drm.fbdev=1"
          ]
          (lib.mkIf config.hardware.nvidia.powerManagement.enable [
            "nvidia.NVreg_TemporaryFilePath=/var/nvidia-suspend"
          ])
        ];
        blacklistedKernelModules = [ "nouveau" ];
      };

      systemd.tmpfiles.rules = lib.mkIf config.hardware.nvidia.powerManagement.enable [
        "d /var/nvidia-suspend 0700 root root -"
      ];

      system.activationScripts.ldconfig = lib.mkForce "";
    };
}
