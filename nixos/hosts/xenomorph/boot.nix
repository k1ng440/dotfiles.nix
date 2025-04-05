{...}: {
  # boot
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.includeDefaultModules = true;
  boot.supportedFilesystems = [ "ntfs" "zfs" "btrfs" ];

  # initrd
  boot.initrd.enable = true;
  boot.initrd.verbose = false;
  boot.initrd.availableKernelModules = [ "zfs" "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];

  # grub
  boot.loader.grub.enable = false;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.devices = ["nodev"];

  # systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor  = false;
  boot.loader.systemd-boot.rebootForBitlocker = true;
}
