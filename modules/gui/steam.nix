_: {
  flake.modules.nixos.programs_steam =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      nixpkgs.overlays = [
        (_: prev: {
          steam-unwrapped = prev.steam-unwrapped.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              sed -i 's/^Name=Steam$/Name=Steam (native)/' \
                $out/share/applications/steam.desktop
            '';
          });
        })
      ];

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
        package = pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
            OBS_VKCAPTURE = true;
            RADV_TEX_ANISO = 16;
          };
          extraLibraries = p: with p; [ atk ];
          extraBwrapArgs = [
            "--bind /persist/${config.hj.directory} $HOME"
            "--bind /run/user /run/user"
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
          niri = {
            settings = {
              # window-rules = [
              #   {
              #     matches = [
              #       {
              #         app-id = "^steam$";
              #         title = "^notificationtoasts_\\\\d+_desktop$";
              #       }
              #     ];
              #     open-focused = false;
              #     open-floating = true;
              #     "default-floating-position x=10 y=10 relative-to=\"bottom-right\"" = _: {};
              #     draw-border-with-background = false;
              #     focus-ring.off = _:{};
              #   }
              # ];
            };
          };
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
