{ lib, ... }:
{
  flake.modules.nixos.wm =
    { config, pkgs, ... }:
    {
      options.custom.programs.wallpaper-go = lib.mkPackageOption pkgs "custom.wallpaper-go" { };

      config = {
        custom.programs.wallpaper-go = pkgs.custom.wallpaper-go.override {
          inherit (pkgs) pqiv;
          extraPackages = [ pkgs.custom.noctalia-ipc ];
        };

        environment.systemPackages = [ config.custom.programs.wallpaper-go ];
      };
    };
}
