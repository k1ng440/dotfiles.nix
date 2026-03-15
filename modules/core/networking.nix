{
  config,
  pkgs,
  ...
}:
{
  networking = {
    hostName = "${config.machine.hostname}";
    networkmanager.enable = true;
    enableIPv6 = true;
    timeServers = [
      "time.google.com"
      "time.cloudflare.com"
      "pool.ntp.org"
    ];
    firewall = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
