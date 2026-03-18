{ inputs, isNixOS, ... }:
let
  platform = if isNixOS then "nixos" else "darwin";
  platformModules = "${platform}Modules";
in
{
  imports = [
    inputs.sops-nix.${platformModules}.sops
    (if isNixOS then inputs.stylix.nixosModules.stylix else inputs.stylix.darwinModules.stylix)
  ]
  ++ (if isNixOS then [ inputs.nix-flatpak.nixosModules.nix-flatpak ] else [ ]);
}
