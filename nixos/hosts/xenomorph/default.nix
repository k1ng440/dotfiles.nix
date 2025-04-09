{
  lib,
  self,
  pkgs,
  ...
}:
{
  nixos-common.audio.enable = true;
  nixos-common.bluetooth.enable = true;

  imports = [
    ./boot.nix
    ./filesystem.nix
    ./disko.nix
    ./hardware.nix
    ./services
    ./system.nix
    ./users.nix
    ./networking.nix
  ];
}
