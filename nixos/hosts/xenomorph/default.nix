{
  lib,
  self,
  pkgs,
  ...
}:
{
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
