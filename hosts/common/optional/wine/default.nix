{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wineWowPackages.waylandFull
    winetricks
  ];

  boot.binfmt.registrations.wine = {
    magicOrExtension = "MZ";
    interpreter = "${pkgs.wineWowPackages.waylandFull}/bin/wine";
  };
}
