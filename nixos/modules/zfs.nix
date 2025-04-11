{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.supportedFilesystems = [
    "ntfs"
    "zfs"
    "btrfs"
  ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
}
