{
  description = "k1ng's NixOS, nix-darwin and Home Manager Configuration";
  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;
      overlays = import ./overlays { inherit inputs; };
      npins = import ./npins;

      mkHost = host: isNixOS: {
        ${host} =
          let
            systemFunc = if isNixOS then lib.nixosSystem else builtins.throw "Unsupported System";
          in
          systemFunc {
            specialArgs = {
              inherit
                self
                inputs
                outputs
                isNixOS
                npins
                ;
              isDarwin = !isNixOS;
              lib = nixpkgs.lib.extend (
                self: super: {
                  custom = import ./lib { inherit (nixpkgs) lib; };
                }
              );
            };
            modules = [
              ./hosts/${if isNixOS then "nixos" else "darwin"}/${host}
              (
                {
                  config,
                  pkgs,
                  lib,
                  ...
                }:
                {
                  nixpkgs.overlays = [ overlays.default ];
                  nixpkgs.config.allowUnfreePredicate =
                    pkg:
                    builtins.elem (lib.getName pkg) [
                      "stremio-shell"
                      "stremio-server"
                    ];
                }
              )
            ];
          };
      };

      mkHostConfigs =
        hosts: isNixOS: lib.foldl (acc: set: acc // set) { } (lib.map (host: mkHost host isNixOS) hosts);

      readHosts = folder: lib.attrNames (builtins.readDir ./hosts/${folder});

      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      inherit overlays;
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "stremio-shell"
                "stremio-server"
              ];
          };
          stremio-custom = pkgs.callPackage ./packages/stremio.nix { };
        in
        {
          stremio = stremio-custom;
        }
      );

      nixosConfigurations = mkHostConfigs (readHosts "nixos") true;
      devShells = forAllSystems (
        system:
        import ./shell.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          checks = self.checks.${system};
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (self.checks.${system}.pre-commit-check) config;
          inherit (config) package configFile;
          script = ''
            ${pkgs.lib.getExe package} run --all-files --config ${configFile}
          '';
        in
        pkgs.writeShellScriptBin "pre-commit-run" script
      );

      checks = forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt.enable = true;
            nil.enable = true;
            deadnix.enable = false;
            statix.enable = false;
          };
        };
      });
    };

  /**
    IMPORTS
  */
  inputs = {
    # Core Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # System management
    home-manager = {
      url = "github:nix-community/home-manager";
      # url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Security and secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Styling and theming
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development tools
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland window manager
    hyprland = {
      url = "github:hyprwm/Hyprland";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # Utility flakes
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal Repositories
    # Authenticate via ssh and use shallow clone
    nix-secrets = {
      url = "git+ssh://git@gitlab.com/k1ng4401/nix-secrets.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stub-flake.url = "github:k1ng440/stub-flake"; # A completely empty flake
  };
}
