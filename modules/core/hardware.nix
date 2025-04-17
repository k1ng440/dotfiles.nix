{ ... }:
{
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;

  hardware = {
    graphics.enable32Bit = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    ledger.enable = true;
  };
}
