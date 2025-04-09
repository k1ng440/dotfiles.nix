{ pkgs, ... }:
{
  hardware = {
    sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
      # disabledDefaultBackends = [ "escl" ];
    };
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = false;
    graphics.enable = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    ledger.enable = true;

  };

  local.hardware-clock.enable = false;
}

