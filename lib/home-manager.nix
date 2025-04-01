{
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  specialArgs,
  host,
}:
let
  pkgs = nixpkgs-unstable.legacyPackages.${specialArgs.system};
  username = specialArgs.username;
  sharedConfig = {
    extraSpecialArgs = specialArgs;
  };
in
{
  module = {
    home-manager = {
      useGlobalPkgs = true;
      backupFileExtension = "backup";
      useUserPackages = true;

      users."${username}" = {
        imports = [
          host.homeModules
        ];
      };
    } // sharedConfig;
  };

  configuration = home-manager.lib.homeManagerConfiguration (
    {
      pkgs = pkgs;
      modules = [
        host.homeModules
      ];
    }
    // sharedConfig
  );
}
