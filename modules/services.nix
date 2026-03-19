{ config, ... }:
{

  # For gnome keyring
  programs.seahorse.enable = true;

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
    upower.enable = true;
    devmon.enable = true; # Automatic device mounting
    udisks2.enable = true;
    power-profiles-daemon.enable = true;
    accounts-daemon.enable = true;

    avahi = {
      enable = !config.machine.computed.isMinimal;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = config.machine.hostType == "workstation";
      };
    };

    smartd = {
      enable = !config.machine.computed.isMinimal && !config.machine.platform.isVirtualMachine;
      autodetect = true;
    };

  };
}
