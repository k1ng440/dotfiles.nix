{
  flake.modules.nixos.services_syncthing =
    { config, ... }:
    let
      inherit (config.custom.constants) user home;
    in
    {
      services.syncthing = {
        enable = true;
        inherit user;
        group = user;
        dataDir = home;
        openDefaultPorts = true;
      };
    };
}
