{ config, ... }:
let
  sshPort = config.hostSpec.networking.ports.tcp.ssh;
in {
  services.openssh = {
    enable = true;
    ports = [ sshPort ];

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
      GatewayPorts = "clientspecified";
    };

    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ sshPort ];
}
