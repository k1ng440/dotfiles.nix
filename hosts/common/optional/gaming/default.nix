{
  pkgs,
  config,
  lib,
  ...
}:
let
  kdegamemode = import (lib.custom.relativeToRoot "home/common/scripts/kdegamemode.nix") {
    inherit pkgs;
  };
  hyprgamemode = import (lib.custom.relativeToRoot "home/common/wayland/hyprland/hyprgamemode.nix") {
    inherit pkgs kdegamemode;
    inherit (config) machine;
  };
in
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
          renice = 0;
        };
        custom = {
          # Using a single store path to avoid 256-character truncation in gamemode.ini
          start = "${hyprgamemode}/bin/hyprgamemode on";
          end = "${hyprgamemode}/bin/hyprgamemode off";
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
  ];
}
