{
  description = "Home Manager configuration of k1ng";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kubectl = {
      url = "github:LongerHV/kubectl-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = { 
      url = "github:ghostty-org/ghostty"; 
    };
    color-schemes = {
      url = "github:mbadolato/iTerm2-Color-Schemes";
      flake = false;
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ghostty, color-schemes, nixgl, ... }:
    let
      system = "x86_64-linux";
    in {
      nixpkgs.config.allowUnfree = true;
      homeConfigurations."k1ng" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
        };    
        extraSpecialArgs = { 
          inherit inputs; 
          inherit system;
          inherit color-schemes;
        };
        modules = [
          ./home.nix
          ./nix_modules
          ./nvim
        ];
      };
    };
}
