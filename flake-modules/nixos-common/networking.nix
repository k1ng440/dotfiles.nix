{lib, config, pkgs, ...}: {
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  networking.enableIPv6 = true;
}
