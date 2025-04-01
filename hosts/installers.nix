{
  variables,
  hosts,
  systems,
  disko,
  nixpkgs,
  nixos-generators,
  theme,
  ...
}:
let
  configureInstaller = import ../lib/install/configure-installer.nix;

  args = {
    inherit (nixpkgs) lib;
    inherit disko variables nixos-generators nixpkgs theme;
  };
in
nixpkgs.lib.genAttrs systems (
  system:
  builtins.mapAttrs (
    _: hostConf:
    configureInstaller (
      {
        host = hostConf;
        system = system;
      }
      // args
    )
  ) hosts
)
