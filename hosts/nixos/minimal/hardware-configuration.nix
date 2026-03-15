{ lib, ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader.grub.device = "/dev/sda"; # or "nodev" for EFI

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
