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
      ...
    }:
    {
      environment.systemPackages = [
        pkgs.karere
        pkgs.gst_all_1.gst-plugins-base
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
      ];
      programs.firejail = {
        enable = true;
        wrappedBinaries = {
          karere = {
            executable = lib.getExe pkgs.karere;
            extraArgs = [
              "--ignore=nodbus"
              "--ignore=dbus-user"
              "--noprofile"
              "--env=GST_PLUGIN_PATH=${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
              "--env=WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1"
              "--env=RUST_BACKTRACE=1"
              "--env=GTK_USE_PORTAL=0"
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
