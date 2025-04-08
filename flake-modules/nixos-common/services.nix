{...}: {
  # SMART monitoring
  services.smartd = {
    enable = true;
    notifications.mail.enable = true;
  };

  # Firmware updates
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  # Profiling
  services.sysprof.enable = true;
}
