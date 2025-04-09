{hostname, ...}: {
  imports = [
    ../../hosts/${hostname}
    ../../nixos/drivers
    ../../nixos/core
  ];
  # Enable GPU Drivers
  drivers.amdgpu.enable = false;
  drivers.nvidia.enable = false;
  drivers.intel.enable = false;
  vm.guest-services.enable = true;
}
