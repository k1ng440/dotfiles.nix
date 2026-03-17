{
  inputs,
  outputs,
  nixpkgs,
  nix-darwin,
  overlays,
  npins,
}:
let
  inherit (nixpkgs) lib;
in
host: isNixOS:
let
  systemFunc = if isNixOS then lib.nixosSystem else nix-darwin.lib.darwinSystem;
in
systemFunc {
  specialArgs = {
    inherit
      inputs
      outputs
      isNixOS
      npins
      ;
    inherit (inputs) self;
    isHomeManager = false;
    isDarwin = !isNixOS;
    lib = nixpkgs.lib.extend (
      _self: _super: {
        custom = import ../lib { inherit (nixpkgs) lib; };
      }
    );
  };
  modules = [
    ../hosts/${if isNixOS then "nixos" else "darwin"}/${host}
    ../modules/hosts/${if isNixOS then "nixos" else "darwin"}/unfree.nix
    (if isNixOS then inputs.stylix.nixosModules.stylix else inputs.stylix.darwinModules.stylix)
    (_: {
      nixpkgs.overlays = lib.flatten (lib.attrValues overlays);
    })
  ]
  ++ lib.optionals isNixOS [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
}
