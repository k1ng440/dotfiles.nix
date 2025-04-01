{
  description = "Home Manager configuration of k1ng";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-24.11";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    kubectl = {
      url = "github:LongerHV/kubectl-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };

    # neovim external plugins
    nvim-plugin-vim-header = {
      url = "github:alpertuna/vim-header";
      flake = false;
    };
    nvim-plugin-blink-ripgrep = {
      url = "github:mikavilpas/blink-ripgrep.nvim";
      flake = false;
    };
    nvim-plugin-git-conflict = {
      url = "github:akinsho/git-conflict.nvim/v2.1.0";
      flake = false;
    };
    nvim-plugin-img-clip = {
      url = "github:HakonHarnes/img-clip.nvim/v0.6.0";
      flake = false;
    };
    nvim-plugin-godoc = {
      url = "github:fredrikaverpil/godoc.nvim/v2.3.0";
      flake = false;
    };
    nvim-plugin-other = {
      url = "github:rgroli/other.nvim";
      flake = false;
    };
    nvim-plugin-format-ts-errors = {
      url = "github:davidosomething/format-ts-errors.nvim";
      flake = false;
    };
    nvim-plugin-inc-rename = {
      url = "github:smjonas/inc-rename.nvim";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-generators,
    nixos-hardware,
    home-manager,
    ghostty,
    color-schemes,
    nixgl,
    kubectl,
    zen-browser,
    ...
  }: let
    nvimLib = import ./lib/nvim-plugin-utils.nix {
      lib = nixpkgs.lib; # or nixpkgs-unstable.lib depending on what you're using
    };

    theme = import ./theme.nix;
    extraArgs = {
      inputs = inputs;
      variables = import ./variables.nix;
      rawNvimPlugins = nvimLib.fromInputs inputs "nvim-plugin-";
      theme = theme;
    };

    specialArgs = import ./lib/special-args.nix (
      {
        inherit nixpkgs-unstable nixos-hardware zen-browser;
      }
      // extraArgs
    );

    configurations =
      builtins.mapAttrs
      (_: hostConf: {
        inherit (hostConf) info nixosModules homeModules;
        homeManager = import ./lib/home-manager.nix {
          inherit nixpkgs nixpkgs-unstable home-manager;
          specialArgs = specialArgs.x64SpecialArgs;
          host = hostConf;
        };
      })
      {
        rog-beast = import ./hosts/rog-beast {};
      };

    osConfigurations =
      nixpkgs.lib.filterAttrs (
        _: hostConf: builtins.hasAttr "nixosModules" hostConf
      )
      configurations;

    args =
      {
        inherit (extraArgs) variables;
        inherit specialArgs home-manager;
        configurations = osConfigurations;
      }
      // inputs;

    hosts = import ./hosts args;
    installers = import ./hosts/installers.nix (
      {
        hosts = hosts.hosts;
        systems = hosts.allSystems;
        theme = theme;
      }
      // args
    );
  in {
    confs = configurations;
    homeConfigurations =
      builtins.mapAttrs (
        _: hostConf: hostConf.homeManager.configuration
      )
      configurations;

    hosts = hosts;
    nixosConfigurations = hosts.nixosConfigurations;
    packages = hosts.packages;
    installers = installers;

    formatter = nixpkgs.lib.genAttrs hosts.allSystems (
      system: nixpkgs.legacyPackages.${system}.alejandra
    );
  };
}
