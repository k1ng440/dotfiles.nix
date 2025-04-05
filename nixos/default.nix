{
  self,
  inputs,
  lib,
  mylib,
  ...
}: let
  inherit
    (inputs)
    disko
    flake-registry
    flake-parts
    nixos-hardware
    nixpkgs
    nixpkgs-unstable
    ;

  nixosSystem = args:
    (lib.makeOverridable lib.nixosSystem) (
      lib.recursiveUpdate args {
        modules =
          args.modules
          ++ [
            {
              config.nixpkgs.pkgs = lib.mkDefault args.pkgs;
              config.nixpkgs.localSystem = lib.mkDefault args.pkgs.stdenv.hostPlatform;
            }
          ];
      }
    );

  modules = mylib.rakeLeaves ./modules;

  defaultModules = [
    # make flake inputs accessible in NixOS
    {
      _module.args.self = self;
      _module.args.inputs = inputs;
      _module.args.lib = lib;
    }
    # load common modules
    (
      {...}: {
        imports = [
          disko.nixosModules.disko
          modules.i18n
          modules.minimal-docs
          modules.nix
          modules.openssh
          modules.server
          modules.tailscale
        ];
      }
    )
  ];

  pkgs.x86_64-linux = import nixpkgs {
    inherit lib;
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  pkgs.x86_64-linux-unstable = import nixpkgs-unstable {
    inherit lib;
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  imports = [
    ./images
  ];

  flake.nixosConfigurations = {
    xenomorph = nixosSystem {
      pkgs = pkgs.x86_64-linux;
      specialArgs = {
        nixpkgs-unstable = pkgs.x86_64-linux-unstable;
      };
      modules =
        defaultModules
        ++ [
          # https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
          nixos-hardware.nixosModules.common-pc
          # nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          nixos-hardware.nixosModules.common-cpu-amd-zenpower
        ]
        ++ [
          modules.tcp-hardening
          modules.tcp-optimizations
          modules.tmpfs
          modules.fs-trim
        ]
        ++ [
          (import ./hosts/xenomorph)
        ];
    };
  };
}
