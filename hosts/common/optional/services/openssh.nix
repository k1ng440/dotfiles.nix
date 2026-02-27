{ config, ... }:
{
  services = {
    openssh = {
      enable = true;
      ports = [ config.machine.networking.ports.tcp.ssh ];

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        StreamLocalBindUnlink = "yes";
        GatewayPorts = "clientspecified";
        X11Forwarding = false;
      };

      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
    fail2ban = {
      enable = true;
      maxretry = 3;
      bantime = "1h";
      bantime-increment.enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = config.networking.firewall.allowedTCPPorts ++ [
    config.machine.networking.ports.tcp.ssh
  ];
}
