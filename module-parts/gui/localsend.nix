{
  flake.modules.nixos.programs_localsend =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.localsend ];

      networking.firewall = {
        allowedTCPPorts = [ 53317 ];
        allowedUDPPorts = [ 53317 ];
      };

      custom = {
        programs = {
          which-key = {
            menus = {
              l = {
                desc = "Localsend";
                cmd = lib.getExe pkgs.localsend;
              };
            };
          };
        };
        persist = {
          home = {
            directories = [
              ".local/share/org.localsend.localsend_app"
            ];
          };
        };
      };
    };
}
