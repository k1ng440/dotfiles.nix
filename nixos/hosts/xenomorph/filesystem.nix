{ lib, ... }:
{
  fileSystems."/" = {
    fsType = lib.mkDefault "btrfs";
  };
  fileSystems."/nix" = {
    fsType = lib.mkDefault "btrfs";
  };
  fileSystems."/home" = {
    fsType = lib.mkDefault "btrfs";
  };
  services.btrfs.autoScrub.enable = true;
}
