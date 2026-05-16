{
  flake.modules.nixos.programs_anki =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.anki-bin ];

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
            ];
            open-floating = true;
          }
        ];
        programs.which-key.menus = {
          a = {
            desc = "Anki";
            cmd = lib.getExe pkgs.anki-bin;
          };
        };
      };
    };
}
