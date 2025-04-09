localFlake: {
  self,
  config,
  inputs,
  withSystem,
  lib,
  ...
}:
let
  system = "x86_64-linux";
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
in
{
  flake.homeConfigurations = {
   k1ng = withSystem system ({pkgs, ...}: homeManagerConfiguration {
       pkgs = inputs.nixpkgs.legacyPackages.${system};
       extraSpecialArgs = {
        inherit system inputs;
       };
       modules = [
         # self.homeManagerModules.de
	 inputs.nix-index-database.hmModules.nix-index
         ./nvim
         {
           home = {
             username = "k1ng";
             homeDirectory = "/home/k1ng";
             stateVersion = "24.11";
           };
         }
       ];
     });
   };
}
