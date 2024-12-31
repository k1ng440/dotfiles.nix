{
  description = "Home Manager configuration of k1ng";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kubectl = {
      url = "github:LongerHV/kubectl-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghosttyhm.url = "github:clo4/ghostty-hm-module";
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ghosttyhm, ghostty, nixgl, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      allowed-unfree-packages = [ "nvidia" ];
    in {
      nixpkgs.config.allowUnfree = true;
      homeConfigurations."k1ng" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { 
          inherit inputs; 
          inherit system;
          inherit allowed-unfree-packages;
        };
        modules = [
          ./home.nix
          ./nix_modules
          ./nvim
          ghosttyhm.homeModules.default
        ];
      };
    };
}
