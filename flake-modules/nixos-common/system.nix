{lib, ...}: {
  # Define default system version
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = lib.mkDefault "24.11";

  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
