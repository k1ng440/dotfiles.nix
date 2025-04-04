{ config, lib, pkgs, ... }: {

  #boot.supportedFilesystems = [ "zfs" ];
  # services.zfs.autoScrub.enable = true;
  # services.zfs.trim.enable = true;
}
