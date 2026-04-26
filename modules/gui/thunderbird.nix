{
  flake.modules.nixos.programs_thunderbird =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = [ pkgs.thunderbird-bin ];

      custom = {
        startup = [
          {
            app-id = "thunderbird";
            spawn = [ (lib.getExe pkgs.thunderbird-bin) ];
            workspace = 4;
            delay = 3;
          }
        ];
        programs.niri.settings.window-rules = [
          {
            matches = [
              {
                app-id = "^thunderbird$";
                title = "^Write:|^Address Book";
              }
            ];
            open-floating = true;
          }
          {
            matches = [
              {
                app-id = "^thunderbird$";
                title = "^Alert$|^Connection Error|^Login Failed|^Password Required|^Security Exception";
              }
            ];
            open-floating = true;
          }
        ];
        persist = {
          home.directories = [ ".thunderbird" ];
        };
      };
    };
}
