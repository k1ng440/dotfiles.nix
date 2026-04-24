_: {
  flake.modules.nixos.programs_telegram =
    {
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = [ pkgs.telegram-desktop ];
      programs.firejail = {
        enable = true;
        wrappedBinaries = {
          Telegram = {
            executable = lib.getExe pkgs.telegram-desktop;
            profile = "${pkgs.firejail}/etc/firejail/Telegram.profile";
            extraArgs = [
              "--ignore=private-bin"
              "--ignore=private-lib"
              "--ignore=private-etc"
              "--ignore=nodbus"
              "--ignore=dbus-user"
            ];
          };
        };
      };

      xdg.mime.defaultApplications = {
        "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      };

      custom = {
        programs.which-key.menus = {
          m = {
            desc = "Messengers";
            submenu = {
              t = {
                desc = "Telegram";
                cmd = lib.getExe pkgs.telegram-desktop;
              };
            };
          };
        };
        persist = {
          home.directories = [
            ".local/share/TelegramDesktop"
          ];
        };
      };
    };

  flake.modules.nixos.programs_whatsapp =
    {
      pkgs,
      lib,
      outputs,
      ...
    }:
    {
      nixpkgs.overlays = [
        (_: prev: {
          karere = prev.karere.overrideAttrs (
            old:
            let
              sources = outputs.libCustom.nvFetcherSources prev;
            in
            {
              version = sources.karere.version;
              src = sources.karere.src;
              cargoDeps = prev.rustPlatform.fetchCargoVendor {
                inherit (sources.karere) src;
                pname = "karere";
                version = sources.karere.version;
                hash = "sha256-SfujfVp8Xy39AWzL3QHqbMqfLHrCPKgJAqh950nLaBY=";
              };
              buildInputs = old.buildInputs ++ [
                prev.gsettings-desktop-schemas
              ];
            }
          );
        })
      ];

      environment.pathsToLink = [ "/share/gsettings-schemas" ];

      environment.systemPackages = [
        pkgs.karere
        pkgs.gst_all_1.gst-plugins-base
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
        pkgs.glib
      ];
      programs.firejail = {
        enable = true;
        wrappedBinaries = {
          karere = {
            executable = lib.getExe pkgs.karere;
            extraArgs = [
              "--noprofile"
              "--ignore=nodbus"
              "--ignore=dbus-user"
              "--ignore=noroot"
              "--env=WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1"
              "--env=RUST_BACKTRACE=1"
              "--env=GTK_USE_PORTAL=0"
              "--env=GST_PLUGIN_PATH=${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
              "--env=XDG_DATA_DIRS=${pkgs.karere}/share/gsettings-schemas/karere-${pkgs.karere.version}:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:/run/current-system/sw/share"
              "--whitelist=/nix/store"
            ];
          };
        };
      };
      xdg.mime.defaultApplications = {
        "x-scheme-handler/whatsapp" = "karere.desktop";
      };
      custom = {
        programs.which-key.menus = {
          m = {
            desc = "Messengers";
            submenu = {
              w = {
                desc = "Whatsapp";
                cmd = lib.getExe pkgs.karere;
              };
            };
          };
        };
        persist = {
          home.directories = [
            ".local/share/karere"
          ];
        };
      };
    };
}
