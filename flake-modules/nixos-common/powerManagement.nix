{ lib, ... }:
{
  powerManagement.enable = lib.mkDefault true;
  hardware.nvidia.powerManagement.enable = lib.mkDefault true;
}
