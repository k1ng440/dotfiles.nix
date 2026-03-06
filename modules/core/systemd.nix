{ pkgs, ... }:
{
  systemd = {
    timers.clear-tmp = {
      description = "Clear /tmp weekly";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };

    services.clear-tmp = {
      description = "Clear /tmp directory";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/find /tmp -type f -atime +7 -delete";
      };
    };
  };
}
