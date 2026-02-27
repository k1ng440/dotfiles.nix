{ pkgs, config, ... }:
{
  # Services to start
  services = {
    libinput.enable = true; # Input Handling
    fstrim.enable = true; # SSD Optimizer
    gvfs.enable = true; # For Mounting USB & More
    openssh.enable = true; # Enable SSH
    blueman.enable = true; # Bluetooth Support
    tumbler.enable = true; # Image/video preview
    gnome.gnome-keyring.enable = true;
    dbus.implementation = "broker";

    # TODO: Only enable this on truested networks.
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    smartd = {
      enable = !config.machine.computed.isMinimal && !config.machine.platform.isVirtualMachine;
      autodetect = true;
    };

    syslogd = {
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
  };
}
