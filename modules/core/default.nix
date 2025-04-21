{ ... }:
{
  imports = [
    ./boot.nix
    ./greetd.nix
    ./hardware.nix
    ./networking.nix
    ./packages.nix
    ./security.nix
    ./services.nix
    ./hardware.nix
    ./system.nix
    ./xdg-portal.nix
    ./applications.nix
    ./udev.nix
  ];
}
