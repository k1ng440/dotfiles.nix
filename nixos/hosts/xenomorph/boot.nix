{...}: {
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.supportedFilesystems = [
    "ntfs"
    "zfs"
  ];
  boot.loader.grub.devices = ["nodev"];
}
