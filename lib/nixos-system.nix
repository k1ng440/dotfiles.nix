{
  nixpkgs,
  nixos-generators,
  home-manager,
  system,
  specialArgs,
  host,
  disko,
}:
nixpkgs.lib.nixosSystem {
  inherit system specialArgs;
  modules = [
    host.configuration.nixosModules
    disko.nixosModules.disko
    host.homeManager.module
    {
      # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
      nix.registry.nixpkgs.flake = nixpkgs;

      # make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
      environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
      nix.nixPath = [ "/etc/nix/inputs" ];
    }

    home-manager.nixosModules.home-manager
    host.configuration.nixosModules

    nixos-generators.nixosModules.all-formats
    {
    }
  ];
}
