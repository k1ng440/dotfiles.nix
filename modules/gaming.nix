{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (lib.elem "gaming" config.machine.capabilities) {
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        gamescopeSession.enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        extraPackages = with pkgs; [
          gamemode
          pkgsi686Linux.gamemode
        ];
        protontricks = {
          enable = true;
        };
      };

      gamescope = {
        enable = true;
        capSysNice = false;
        package = pkgs.gamescope;
      };

      # To run steam games in game mode, add the following to the game's properties from within steam
      # gamemoderun %command%
      gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          #see gamemode man page for settings info
          general = {
            softrealtime = "auto";
            inhibit_screensaver = 1;
            renice = 0;
          };
          custom = {
          };
        };
      };
    };

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };

    environment.systemPackages = with pkgs; [
      bottles
      vulkan-tools
      corefonts
      steamtinkerlaunch
      xrandr
      xwininfo
      libva
      libva-utils
      pkgs.unstable.lutris
      pkgsi686Linux.gamemode
    ];
  };
}
