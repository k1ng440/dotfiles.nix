{ pkgs, ... }:
let
  PRIMARYUSBID = "PARTUUID=02a72519-01";
  BACKUPUSBID = "UUID=b501f1b9-7714-472c-988f-3c997f146a18";
in
{
  # boot
  boot.kernelModules = [ "r8169" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.includeDefaultModules = true;
  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
  ];

  # zfs
  # boot.zfs.forceImportRoot = true;
  # boot.zfs.devNodes = "/dev/disk/by-label";

  # initrd
  boot.initrd.enable = true;
  boot.initrd.verbose = true;
  boot.initrd.kernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "sd_mod"
    "r8169"
    "uas"
    "usbcore"
    "usb_storage"
    "vfat"
    "nls_cp437"
    "nls_iso8859_1"
  ];

  # systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.rebootForBitlocker = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  # misc
  boot.tmp.cleanOnBoot = true;
}
