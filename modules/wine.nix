{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.machine.services.wine {
    environment.systemPackages = with pkgs; [
      wineWow64Packages.staging
      winetricks
    ];

    boot.binfmt.registrations.wine = {
      magicOrExtension = "MZ";
      interpreter = "${pkgs.wineWow64Packages.staging}/bin/wine";
    };
  };
}
