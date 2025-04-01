{
  variables,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    speedtest-cli
    bandwhich
    wirelesstools
  ];

  networking = {
    enableIPv6 = false;

    nameservers = variables.nameservers;

    firewall = {
      enable = true;
      allowPing = true;
      logReversePathDrops = true;
    };

    networkmanager = {
      enable = true;
      unmanaged = ["docker0"];
    };
  };

  # Can speed up boot times
  systemd.services.NetworkManager-wait-online.enable = false;
}
