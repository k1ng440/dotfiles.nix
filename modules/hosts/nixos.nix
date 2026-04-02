{
  config,
  inputs,
  ...
}:
let
  mkNixos =
    host:
    {
      system ? "x86_64-linux",
      isVm ? false,
      user ? "k1ng",
      extraConfig ? { },
    }:
    inputs.nixpkgs-patcher.lib.nixosSystem {
      inherit system;

      nixpkgsPatcher.inputs = inputs; # for nixpkgs-patcher to patch

      specialArgs = {
        inherit
          inputs
          isVm
          user
          ;
        outputs = config.flake;
      };

      modules = [
        {
          nixpkgs.config.allowUnfree = true;
        }
        {
          config.custom.constants = rec {
            inherit host isVm user;
            home = "/home/${user}";
            isLaptop = false;
            dots = "${home}/nix/nix-config";
            projects = "${home}/Projects";
          };
        }
        config.flake.modules.nixos."host_${host}"
        config.flake.modules.nixos.core
        inputs.hjem.nixosModules.default
        inputs.nix-index-database.nixosModules.nix-index
        inputs.noctalia.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
        inputs.sops-nix.nixosModules.sops
        extraConfig
      ];
    };
  mkVm = host: mkNixosArgs: mkNixos host (mkNixosArgs // { isVm = true; });
in
{
  flake.nixosConfigurations = {
    xenomorph = mkNixos "xenomorph" { };
    xenomorph-vm = mkVm "xenomorph" { };
    vm = mkVm "vm" { };
  };
}
