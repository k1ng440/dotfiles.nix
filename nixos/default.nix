localFlake: {
  # Arguments provided by flake-parts module system & perSystem
  config,
  # Module system config object
  inputs,
  # Flake inputs passed down
  lib,
  # Nixpkgs lib and flake-parts lib merged
  mylib,
  # Custom lib
  self,
  # The flake's self reference
  ...
}: let
  inherit
    (inputs)
    disko
    nixos-generators
    nixos-hardware
    nixpkgs
    nixpkgs-unstable
    ;

  # Load modules from ./modules directory
  modules = mylib.rakeLeaves ./modules;

  # Define default/common modules
  defaultModules = [
    # make flake inputs accessible in NixOS module arguments
    {
      _module.args.self = self;
      _module.args.inputs = inputs;
    }
    # load common modules
    ({...}: {
      imports = [
        disko.nixosModules.disko
        modules.i18n
        modules.minimal-docs
        modules.nix
        modules.openssh
        modules.server
        modules.fish
        # modules.zerotierone
      ];
    })
  ];
in {
  imports = [./images];

  flake.nixosConfigurations = {
    xenomorph = lib.nixosSystem {
      specialArgs = {
        inherit lib mylib;
        # Note: self, inputs, lib, etc., are passed via _module.args in defaultModules
      };

      modules =
        defaultModules
        ++ [
          nixos-hardware.nixosModules.common-pc
          # nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          nixos-hardware.nixosModules.common-cpu-amd-zenpower
        ]
        ++ [
          modules.tcp-hardening
          modules.tcp-optimizations
          modules.tmpfs
          modules.fs-trim
          modules.fish
        ]
        ++ [./hosts/xenomorph];
    };
  };
}
