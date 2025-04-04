{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (inputs)
    disko
    flake-registry
    nixos-hardware
    nixpkgs
    pkgs-unstable
    ;

  nixosSystem =
    args:
    (lib.makeOverridable lib.nixosSystem) (
      lib.recursiveUpdate args {
        modules = args.modules ++ [
          {
            config.nixpkgs.pkgs = lib.mkDefault args.pkgs;
            config.nixpkgs.pkgs-unstable = lib.mkDefault args.pkgs-unstable;
            config.nixpkgs.localSystem = lib.mkDefault args.pkgs.stdenv.hostPlatform;
          }
        ];
      }
    );

  hosts = lib.rakeLeaves ./hosts;
  modules = lib.rakeLeaves ./modules;

  defaultModules = [
    # make flake inputs accessible in NixOS
    {
      _module.args.self = self;
      _module.args.inputs = inputs;
      _module.args.lib = lib;
    }
    # load common modules
    (
      { ... }:
      {
        imports = [
          disko.nixosModules.disko
          ethereum-nix.nixosModules.default
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
  }
in
{
  imports = [
    ./images
  ];

  flake.nixosConfigurations = {
    nuc-1 = nixosSystem {
      pkgs = pkgs.x86_64-linux;
      pkgs-unstable = pkgs.x86_64-linux-unstable;
      modules =
        defaultModules
        ++ [
            # https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
            nixos-hardware.nixosModules.common-pc
            nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
            nixos-hardware.nixosModules.common-cpu-amd-zenpower
        ]
        ++ [
          modules.serial-console
          modules.tcp-hardening
          modules.tcp-optimizations
          modules.tmpfs
          modules.fs-trim
        ]
        ++ [ hosts.xenomorph ];
    };
  };
}
