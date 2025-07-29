{
  config,
  pkgs,
  options,
  ...
}:
{
  networking = {
    hostName = "${config.machine.hostname}";
    networkmanager.enable = true;
    enableIPv6 = true;
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
    firewall = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
