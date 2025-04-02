{ nixos-generators, }:
{

  formatters =
    { hostPlatform, config, ... }:
    {
      imports = [
        nixos-generators.nixosModules.all-formats
      ];

      nixpkgs.hostPlatform = "x86_64-linux";
    };
}
