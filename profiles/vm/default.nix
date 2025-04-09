{hostname, ...}: {
  imports = [
    ../../hosts/${hostname}
    ../../nixos/drivers
    ../../nixos/core
  ];
  # Enable GPU Drivers
  drivers.nvidia.enable = false;
  vm.guest-services.enable = true;
}
