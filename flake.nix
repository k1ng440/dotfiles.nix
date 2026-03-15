{
  description = "k1ng's NixOS, nix-darwin and Home Manager Configuration";
  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      overlays = import ./overlays { inherit inputs; };
      npins = import ./npins;
      eachSystem = lib.genAttrs (import inputs.systems);

      mkHost = import ./lib/mkHost.nix {
        inherit inputs overlays npins;
        inherit (inputs) nixpkgs nix-darwin;
        inherit (inputs.self) outputs;
      };

      mkHostConfigs =
        hosts: isNixOS:
        lib.listToAttrs (
          lib.map (host: {
            name = host;
            value = mkHost host isNixOS;
          }) hosts
        );

      readHosts = folder: lib.attrNames (builtins.readDir ./hosts/${folder});
    in
    {
      inherit overlays;
      nixosConfigurations = mkHostConfigs (readHosts "nixos") true;
      darwinConfigurations = mkHostConfigs (readHosts "darwin") false;

      devShells = eachSystem (
        _system:
        import ./shell.nix {
          pkgs = inputs.nixpkgs.legacyPackages.${_system};
          checks = inputs.self.checks.${_system};
        }
      );

      formatter = eachSystem (
        _system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${_system};
          inherit (inputs.self.checks.${_system}.pre-commit-check) config;
          inherit (config) package configFile;
        in
        pkgs.writeShellScriptBin "pre-commit-run" ''
          ${pkgs.lib.getExe package} run --all-files --config ${configFile}
        ''
      );

      checks = eachSystem (_system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${_system}.run {
          src = ./.;
          hooks = {
            nixfmt.enable = true;
            nil.enable = true;
            deadnix.enable = true;
            statix.enable = true;
          };
        };
      });
    };

  inputs = {
    # Core Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # System management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Security and secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utility flakes
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    npins = {
      url = "github:andir/npins";
      flake = false;
    };
    systems.url = "github:nix-systems/default";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal Repositories
    nix-secrets = {
      url = "git+ssh://git@gitlab.com/k1ng4401/nix-secrets.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stub-flake.url = "github:k1ng440/stub-flake";
  };
}
