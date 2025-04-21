{ pkgs, ... }:
{
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
}
