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
      capSysNice = true;
      package = pkgs.unstable.gamescope;
      args = [
        "--rt"
        "--expose-wayland"
      ];
      env = {
        GAMESCOPE_WAYLAND_DISPLAY = "gamescope-0";
        PROTON_USE_SDL = "1";
        PROTON_USE_WAYLAND = "1";
        DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1 = "1";
        DISABLE_LAYER_NV_OPTIMUS_1 = "1";
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
    protonup-qt
    bottles
    vulkan-tools
    nexusmods-app
    corefonts
    xorg.xrandr
    xorg.xwininfo
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
