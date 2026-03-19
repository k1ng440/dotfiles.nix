{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.machine.security.antivirus {
    environment.systemPackages = with pkgs; [ clamav ];
    services.clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
    services.clamav.scanner = {
      enable = true;
      interval = "Sat *-*-* 04:00:00";
    };
  };
}
