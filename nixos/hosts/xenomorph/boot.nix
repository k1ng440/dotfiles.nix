{pkgs, ...}: let
  PRIMARYUSBID = "PARTUUID=02a72519-01";
  BACKUPUSBID = "UUID=b501f1b9-7714-472c-988f-3c997f146a18";
in {
  # boot
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.includeDefaultModules = true;
  boot.supportedFilesystems = ["ntfs" "zfs" "btrfs"];
  boot.zfs.forceImportRoot = true;

  # zfs
  boot.zfs.devNodes = "/dev/disk/by-label";

  # initrd
  boot.initrd.enable = true;
  boot.initrd.verbose = true;

  boot.initrd.kernelModules = [
    "zfs"
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

  boot.kernelModules = ["r8169" "zfs"];

  # boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
  #   mkdir -m 0755 -p /key
  #   sleep 2 # To make sure the usb key has been loaded
  #   mount -n -t vfat -o ro `findfs ${PRIMARYUSBID}` /key || mount -n -t vfat -o ro `findfs ${BACKUPUSBID}` /key
  # '';

  # grub
  # boot.loader.grub.enable = false;
  # boot.loader.grub.efiSupport = false;
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.useOSProber = false;
  # boot.loader.grub.devices = ["nodev"];

  # systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = true;
  boot.loader.systemd-boot.rebootForBitlocker = true;
}
