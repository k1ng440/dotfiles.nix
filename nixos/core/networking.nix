{ pkgs, hostname, options, ... }: {
  networking = {
    hostName = "${hostname}";
    networkmanager.enable = true;
    enableIPv6 = true;
    timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 8080 ];
      allowedUDPPorts = [ ];
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
