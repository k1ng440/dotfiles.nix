{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  hostnameEval = builtins.tryEval config.machine.hostname;
  machineDefined = hostnameEval.success;
  hostname = if machineDefined then hostnameEval.value else null;
in
{
  networking = lib.mkIf machineDefined {
    hostName = "${hostname}";
    networkmanager.enable = true;
    enableIPv6 = true;
    timeServers = options.networking.timeServers.default ++ [
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
