{ ... }:
{
  boot.kernelModules = [
    "coretemp"
    "zfs"
  ];
  boot.supportedFilesystems = [
    "btrfs"
    "zfs"
  ];
}
