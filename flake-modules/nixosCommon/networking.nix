{lib, config, pkgs, ...}: {
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  # Disable IPV6 because my ISP does not provide
  networking.enableIPv6 = false;

  # UTC everywhere!
  time.timeZone = lib.mkDefault "UTC";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };
}
