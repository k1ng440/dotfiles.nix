{inputs, outputs, stateVersion, ...}: let
  supportedSystems = [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
in {
  inherit supportedSystems;

  mkHome = { hostname, username ? "k1ng", desktop ? null, system ? "x86_64-linux" }:
    let
      inherit (inputs.home-manager.lib) homeManagerConfiguration;
      isWorkstation = builtins.isString desktop;
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs outputs desktop hostname system username stateVersion isWorkstation pkgs;
        };
        modules = [ ../../home ];
      };

    mkNixos = { hostname, username ? "k1ng", profile ? "nvidia", desktop ? null, system ? "x86_64-linux", }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isWorkstation = builtins.isString desktop;
    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit system desktop ;
        inherit hostname username profile;
        inherit inputs outputs isISO isWorkstation;
      };
      # If the hostname starts with "iso-", generate an ISO image
      modules =
        let
          cd-dvd =
            if (desktop == null) then
              inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            else
              inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
        in [ ./profiles/${profile} ] ++ inputs.nixpkgs.lib.optionals isISO [ cd-dvd ];
    };
}
