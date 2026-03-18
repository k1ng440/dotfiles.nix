{ isNixOS, ... }:
let
  platform = if isNixOS then "nixos" else "darwin";
in
{
  imports = [
    ./common
    ./core
    ./hosts/${platform}
  ];
}
