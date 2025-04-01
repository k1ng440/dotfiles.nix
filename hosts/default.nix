{
  nixpkgs,
  nixos-generators,
  home-manager,
  self,
  specialArgs,
  configurations,
  ...
}: let
  x64System = specialArgs.x64System;
  x64SpecialArgs = specialArgs.x64SpecialArgs;
  allSystems = [x64System];
  nixosSystem = import ../lib/nixos-system.nix;
  baseArgs = {
    inherit nixpkgs;
    specialArgs = x64SpecialArgs;
  };

  systemArgs =
    {
      inherit nixos-generators home-manager;
      system = x64System;
    }
    // baseArgs;

  hosts =
    builtins.mapAttrs (host: hostConf: {
      name = hostConf.info.name;
      diskPath = hostConf.info.diskPath;
      configuration = {
        inherit (hostConf) nixosModules homeModules;
      };
      homeManager = hostConf.homeManager;
    })
    configurations;
in {
  nixosConfigurations =
    builtins.mapAttrs (
      _: hostConf: nixosSystem ({host = hostConf;} // systemArgs)
    )
    hosts;

  packages."${x64System}" =
    builtins.mapAttrs (
      _: hostConf: self.nixosConfigurations.${hostConf.name}.config.formats
    )
    hosts;

  hosts = hosts;

  allSystems = allSystems;
}
