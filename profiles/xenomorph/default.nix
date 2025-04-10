{lib, hostname, username, inputs, ...}: {
  imports = [
    ../../hosts/${hostname}
    ../../nixos/core
    ../../nixos/drivers
    ./users.nix
  ];


  desktop-environment.enable = true;
  desktop-environment.hyprland = true;
  desktop-environment.solaar.enable = true;


  # Enable Drivers
  audio.enable = true;
  drivers.nvidia.enable = true;
  vm.guest-services.enable = false;
}
