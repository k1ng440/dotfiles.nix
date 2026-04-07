{
  flake.modules.nixos.services_docker =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.distrobox ];
      networking.firewall.trustedInterfaces = [ "docker0" ];

      virtualisation = {
        docker = {
          enable = true;
          daemon.settings = {
            features = {
              cdi = true;
            };
          };
        };
      };
    };
}
