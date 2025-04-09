{lib, hostname, username, inputs}: let
  inherit (lib) mkDefault;
in {

  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower

    ../../hosts/${hostname}
    ../../flake-modules/desktop-environment/nixosModules
    ../../flake-modules/nixos-common
  ];

  fileSystems."/" = {
    fsType = mkDefault "btrfs";
  };
  fileSystems."/nix" = {
    fsType = mkDefault "btrfs";
  };
  fileSystems."/home" = {
    fsType = mkDefault "btrfs";
  };
  services.btrfs.autoScrub.enable = true;
}
