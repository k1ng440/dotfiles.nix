# modules/core/system/boot.nix
{ pkgs, config, lib, inputs, system, ... }:
let
  isPhysicalMachine = config.hostSpec.isPhysicalMachine;
in {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      enable = true;
      verbose = lib.mkDefault false;
      kernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "vfat"
      ];
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        memtest86.enable = true;
      };

      efi = if isPhysicalMachine then {
        canTouchEfiVariables = true;  # Allow modification of EFI variables
        efiSysMountPoint = "/boot";   # EFI system partition mount point
      } else {};
    };
  };
}
