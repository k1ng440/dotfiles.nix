{ pkgs, ... }:
{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };

    # to run steam games in game mode, add the following to the game's properties from within steam
    # gamemoderun %command%
    gamemode = {
      enable = true;
      settings = {
        #see gamemode man page for settings info
        general = {
          softrealtime = "on";
          inhibit_screensaver = 1;
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
}
