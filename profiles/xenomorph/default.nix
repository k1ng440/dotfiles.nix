{lib, hostname, username, inputs, ...}: {
  imports = [
    ../../hosts/${hostname}
    ../../nixos/core
    ../../nixos/drivers
    ./users.nix
  ];

  desktop-environment.enable = true;
  desktop-environment.hyprland = true;

  # Enable GPU Drivers
  drivers.nvidia.enable = true;
  vm.guest-services.enable = false;
}
