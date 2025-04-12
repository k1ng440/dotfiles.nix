{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.local.hardware-clock;
in
{
  options.local.hardware-clock = {
    enable = lib.mkEnableOption "Change Hardware Clock To Local Time";
  };

  config = lib.mkIf cfg.enable { time.hardwareClockInLocalTime = true; };
}
