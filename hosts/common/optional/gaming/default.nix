{ pkgs, ... }:
{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      protontricks = {
        enable = true;
      };
    };

    gamescope = {
      enable = true;
      capSysNice = false;
      package = pkgs.gamescope;
      args = [
        "--rt"
        "--expose-wayland"
        "--backend"
        "sdl"
      ];
      env = {
        GAMESCOPE_WAYLAND_DISPLAY = "gamescope-0";
        PROTON_USE_SDL = "1";
        PROTON_USE_WAYLAND = "1";
        DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1 = "1";
        DISABLE_LAYER_NV_OPTIMUS_1 = "1";

        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
      };
    };

    # To run steam games in game mode, add the following to the game's properties from within steam
    # gamemoderun %command%
    gamemode = {
      enable = true;
      settings = {
        #see gamemode man page for settings info
        general = {
          softrealtime = "auto";
          inhibit_screensaver = 1;
          renice = 15;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 1; # The DRM device number on the system (usually 0), ie. the number in /sys/class/drm/card0/
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
  };

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  environment.systemPackages = with pkgs; [
    mangohud
    bottles
    vulkan-tools
    corefonts
    steamtinkerlaunch
    xrandr
    xwininfo
    libva
    libva-utils
    (pkgs.unstable.lutris.override {
      extraPkgs = pkgs: [
        pkgs.wineWowPackages.stagingFull
        pkgs.winetricks
      ];
    })
  ];
}
