{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.machine.services.openrgb {
    services.hardware.openrgb = {
      package = pkgs.openrgb-with-all-plugins;
      enable = true;
      server = {
        port = 6742;
      };
    };
    environment.systemPackages = [
      pkgs.openrgb-with-all-plugins
    ];
  };
}
