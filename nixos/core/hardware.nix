{ pkgs, ... }:
{
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;

  hardware = {
    sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
      # disabledDefaultBackends = [ "escl" ];
    };
    graphics.enable = true;
    graphics.enable32Bit = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    ledger.enable = true;
  };

  local.hardware-clock.enable = false;
}

