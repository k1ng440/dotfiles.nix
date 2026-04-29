{
  flake.modules.nixos.services_docker =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.distrobox ];
      networking.firewall.trustedInterfaces = [ "docker0" ];

      virtualisation = {
        docker = {
          enable = false;
          rootless = {
            enable = true;
            setSocketVariable = true;
            daemon.settings = {
              storage-driver = "btrfs";
              features.cdi = true;
              default-address-pools = [
                {
                  base = "172.27.0.0/16";
                  size = 24;
                }
              ];
            };
          };
        };
      };

      systemd.user.services.docker = {
        after = [
          "network-online.target"
          "nss-lookup.target"
          "systemd-resolved.service"
        ];
        wants = [ "network-online.target" ];
      };
    };
}
