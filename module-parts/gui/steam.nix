{
  flake.modules.nixos.programs_steam =
    { config, pkgs, ... }:
    {
      programs.steam = {
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
        # get rid of ~/.steam directory:
        # https://github.com/ValveSoftware/steam-for-linux/issues/1890#issuecomment-2367103614
        package = pkgs.steam.override {
          extraBwrapArgs = [
            "--bind /persist/${config.hj.directory} $HOME"
            "--unsetenv XDG_CACHE_HOME"
            "--unsetenv XDG_CONFIG_HOME"
            "--unsetenv XDG_DATA_HOME"
            "--unsetenv XDG_STATE_HOME"
          ];
        };
      };

      programs.gamescope = {
        enable = true;
        capSysNice = false;
        package = pkgs.gamescope;
      };

      programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            softrealtime = "auto";
            inhibit_screensaver = 1;
            renice = 0;
          };
          custom = {
          };
        };
      };

      environment.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      };

      custom.persist = {
        home.directories = [
          ".local/share/applications" # desktop files from steam
          ".local/share/icons/hicolor" # icons from steam
          ".local/share/Steam"
        ];
      };
    };
}
