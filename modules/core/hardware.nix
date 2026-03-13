{ pkgs, lib, ... }:
{
  services.power-profiles-daemon.enable = lib.mkDefault false;
  services.auto-cpufreq.enable = lib.mkDefault true;

  hardware = {
    graphics.enable = true;
    graphics.enable32Bit = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    ledger.enable = true;
  };

  hardware.firmware = with pkgs; [
    linux-firmware
  ];
}
