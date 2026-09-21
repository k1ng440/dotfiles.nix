# ABOUTME: Installs Anki (system-Qt build, fcitx5-safe) into the NixOS system.
# ABOUTME: Wires MIME, which-key, floating window rules, and home persistence.
{
  flake.modules.nixos.programs_anki =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.anki ];

      xdg.mime.defaultApplications = {
        "application/x-apkg" = "anki.desktop";
        "application/x-anki" = "anki.desktop";
        "application/x-ankiaddon" = "anki.desktop";
      };

      custom = {
        persist = {
          home.directories = [ ".local/share/Anki2" ];
        };

        programs.niri.settings.window-rules = [
          {
            matches = [
              {
                app-id = "^net.ankiweb.Anki$";
                title = "^Add$|^Browse|^Edit";
              }
              {
                app-id = "^Anki$";
                title = "^Import File$|^Preferences$|^Statistics$|^Deck Options$|^Card Layout$|^Cards$|^Export$|^Check Database$|^Empty Cards$|^Find Duplicates$|^Manage Note Types$|^Change Notetype$|^About$|^Profile$";
              }
            ];
            open-floating = true;
            background-effect = {
              blur = true;
            };
          }
        ];
        programs.which-key.menus = {
          a = {
            desc = "Anki";
            cmd = lib.getExe pkgs.anki;
          };
        };
      };
    };
}
