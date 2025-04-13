{
  lib,
  hostname,
  username,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower

    ../../hosts/${hostname}
    ../../nixos/core
    ../../nixos/drivers
    ../../modules/core/ai
    ./users.nix
  ];

  nixconfig.desktop-environment.enable = true;
  nixconfig.desktop-environment.hyprland = true;
  nixconfig.desktop-environment.solaar.enable = true;

  # Enable Drivers
  nixconfig.drivers.audio.enable = true;
  nixconfig.drivers.nvidia.enable = true;
  nixconfig.drivers.nvidia.open = true;
  nixconfig.vm.guest-services.enable = false;
}
