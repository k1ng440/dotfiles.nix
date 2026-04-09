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
        persist = {
          home.directories = [ ".thunderbird" ];
        };
      };
    };
}
