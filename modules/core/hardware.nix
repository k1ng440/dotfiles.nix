{
  pkgs,
  config,
  ...
}:
{
  services.power-profiles-daemon.enable = config.machine.hostType == "workstation";
  services.auto-cpufreq.enable = config.machine.hostType == "mobile";

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
