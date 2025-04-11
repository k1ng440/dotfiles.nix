localFlake: { config, inputs, ... }: {

  flake.nixosConfigurations = {
    modules = [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          extraSpecialArgs = {
            inherit inputs;
          };
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          users.k1ng = import ./home.nix;
        };
      }
    ];
  };
}
