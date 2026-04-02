{
  flake.modules.nixos.services_docker =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.distrobox ];

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
