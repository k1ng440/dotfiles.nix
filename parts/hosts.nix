{ self, inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  overlays = import ../overlays { inherit inputs; };

  mkHost = import ../lib/mkHost.nix {
    inherit inputs overlays;
    inherit (inputs) nixpkgs nix-darwin;
    inherit (self) outputs;
  };

  mkHostConfigs =
    hosts: isNixOS:
    lib.listToAttrs (
      lib.map (host: {
        name = host;
        value = mkHost host isNixOS;
      }) hosts
    );

  readHosts =
    folder:
    let
      dir = ../hosts + "/${folder}";
    in
    if builtins.pathExists dir then lib.attrNames (builtins.readDir dir) else [ ];
in
{
  flake = {
    inherit overlays;
    nixosConfigurations = mkHostConfigs (readHosts "nixos") true;
    darwinConfigurations = mkHostConfigs (readHosts "darwin") false;
  };
}
