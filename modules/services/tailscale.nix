{
  flake.modules.nixos.service_tailscale =
    { pkgs, config, ... }:
    {
      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client";
      };

      networking.firewall = {
        allowedUDPPorts = [ config.services.tailscale.port ];
        trustedInterfaces = [ "tailscale0" ];
        checkReversePath = "loose";
      };

      systemd.services.tailscale-resume = {
        description = "Restart Tailscale on resume";
        after = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
          "suspend-then-hibernate.target"
        ];
        wantedBy = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
          "suspend-then-hibernate.target"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/systemctl restart tailscaled";
        };
      };

      environment.systemPackages = [ pkgs.tailscale ];
    };
}
