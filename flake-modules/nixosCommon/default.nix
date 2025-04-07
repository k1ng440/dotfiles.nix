{withSystem, self, lib, config, pkgs, ... }: {

  flake.nixosModules.common = [
    import ./i18n.nix
    import ./minimal-docs.nix
    import ./networking.nix
    import ./nix.nix
    import ./shell.nix
    import ./system-packages.nix
    import ./fs-trim.nix
  ];
}
