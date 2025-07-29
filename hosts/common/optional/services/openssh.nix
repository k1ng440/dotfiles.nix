{ config, ... }: {
  services.openssh = {
    enable = true;
    ports = [ config.machine.networking.ports.tcp.ssh ];

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

  networking.firewall.allowedTCPPorts =
    config.networking.firewall.allowedTCPPorts ++ [ config.machine.networking.ports.tcp.ssh ];
}
