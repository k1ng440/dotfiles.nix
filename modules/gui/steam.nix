_: {
  flake.modules.nixos.programs_steam =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        gamescopeSession.enable = false;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        extraPackages = with pkgs; [
          gamemode
          pkgsi686Linux.gamemode
        ];
        protontricks = {
          enable = true;
        };
        # Get rid of ~/.steam directory:
        # https://github.com/ValveSoftware/steam-for-linux/issues/1890#issuecomment-2367103614
        package = pkgs.steam.override {
          extraPkgs =
            pkgs: with pkgs; [
              libXcursor
              libXi
              libXinerama
              libXScrnSaver
              libpng
              libpulseaudio
              libvorbis
              stdenv.cc.cc.lib
              libkrb5
              keyutils
            ];
          extraEnv = {
            OBS_VKCAPTURE = "1";
            RADV_TEX_ANISO = "16";
          };
          extraBwrapArgs = [
            "--bind /persist/${config.hj.directory} $HOME"
            "--bind /run/user /run/user" # <-- add this
            "--bind /run/wrappers /run/wrappers"
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

      services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };

      environment.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      };

      custom = {
        programs = {
          which-key = {
            menus = {
              s = {
                desc = "Steam";
                cmd = lib.getExe pkgs.steam;
              };
            };
          };
        };
        persist = {
          home.directories = [
            ".local/share/applications" # desktop files from steam
            ".local/share/icons/hicolor" # icons from steam
            ".local/share/Steam"
          ];
        };
      };
    };
}
