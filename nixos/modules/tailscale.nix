{config, ...}: {
  services.tailscale = {
    enable = true;
    interfaceName = "tls0";
    port = 41641;
  };

  networking.firewall = {
    trustedInterfaces = ["tls0"];
    checkReversePath = "loose";
    allowedUDPPorts = [config.services.tailscale.port];
  };
}
