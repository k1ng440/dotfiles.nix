localFlake:
# Arguments provided by flake-parts module system & perSystem
{
  config, # Module system config object
  inputs, # Flake inputs passed down
  lib, # Nixpkgs lib and flake-parts lib merged
  mylib, # Custom lib
  self, # The flake's self reference
  ...
}:
let
  inherit (inputs)
    disko
    nixos-generators
    nixos-hardware
    nixpkgs
    nixpkgs-unstable
    ;

  # Define default/common modules
  defaultModules = [
    # make flake inputs accessible in NixOS module arguments
    {
      _module.args.self = self;
      _module.args.inputs = inputs;
    }
    # # load common modules
    # ({...}: {
    #   # imports = [
    #   # ];
    # })
  ];
in
{
  imports = [
    ./images
  ];

  flake.nixosConfigurations = {
    xenomorph = lib.nixosSystem {
      specialArgs = {
        inherit lib mylib;
        # Note: self, inputs, lib, etc., are passed via _module.args in defaultModules
      };

      modules =
        defaultModules
        ++ [
          disko.nixosModules.disko
          nixos-hardware.nixosModules.common-pc
          nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          nixos-hardware.nixosModules.common-cpu-amd-zenpower
        ]
        ++ [
          self.nixosModules.common
          self.nixosModules.de
          ./hosts/xenomorph
        ];
    };
  };
}
