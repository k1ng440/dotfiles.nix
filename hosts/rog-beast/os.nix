{ ... }:
let
  info = import ./info.nix { };
in
{
  imports = [
    (import ../../modules/core-desktop.nix { diskPath = info.diskPath; })
    # Probably does nothing as it's a vm, but it tests if the installation is successful.
    # ../../modules/core-laptop.nix
    ../../modules/services/bluetooth.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/configs/i3.nix

    info.disko
  ];

  networking.hostName = info.name;
}
