{
  flake.modules.nixos.programs_authenticators =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.proton-authenticator
        pkgs.ente-auth
      ];

      custom = {
        programs = {
          which-key = {
            menus = {
              e = {
                desc = "Ente Authenticator";
                cmd = lib.getExe pkgs.ente-auth;
              };
              # p = { desc = "Proton Authenticator"; exec = lib.getExe pkgs.proton-authenticator; };
            };
          };

          niri.settings = {
            window-rules = [
              {
                matches = [ { app-id = "^io.ente.auth$"; } ];
                open-floating = true;
                default-column-width.fixed = 900;
                default-window-height.fixed = 600;
              }
            ];
          };
        };
      };
    };
}
