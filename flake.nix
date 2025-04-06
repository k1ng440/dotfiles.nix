{
  description = "k1ng's NixOS, nix-darwin and Home Manager Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs @ {
    self,
    flake-parts,
    flake-root,
    home-manager,
    mission-control,
    nixpkgs,
    treefmt-nix,
    devshell,
    sops-nix,
    ...
  }: let
    lib = nixpkgs.lib;
    home-manager-lib = home-manager.lib;
    flake-parts-lib = flake-parts.lib;
    mylib = import ./nix/lib {
      lib = nixpkgs.lib;
    };
    # rawNvimPlugins = helper.filterInputsByPrefix { inherit (nixpkgs) lib; } "nvim-plugin-";
  in (
    flake-parts.lib.mkFlake
    {
      inherit inputs;
      specialArgs = {
        inherit
          lib
          mylib
          home-manager-lib
          flake-parts-lib
          ;
      };
    } (
      {
        withSystem,
        moduleWithSystem,
        flake-parts-lib,
        ...
      }: let
        inherit (flake-parts-lib) importApply;

        flakeModules = {
          desktopEnvironment = importApply ./flake-modules/desktopEnvironment { inherit withSystem self; };
          nixosModules = importApply ./nixos {inherit withSystem moduleWithSystem flake-parts-lib;};
        };

        # # Nix Modules
        # nixModules = importApply ./nix {inherit withSystem moduleWithSystem flake-parts-lib;};
        #
        #
        # # NixOS and Home manager modules
        # homeixModules = importApply ./homeix {inherit withSystem moduleWithSystem flake-parts-lib;};
        #
        # # Home manager modules
        # homeModules = importApply ./home {inherit withSystem moduleWithSystem flake-parts-lib;};
        #
        #   desktopEnvironment = importApply ./flake-modules/desktopEnvironment { inherit withSystem self; };

      in {
        # Debug: https://flake.parts/debug.html
        debug = true;
        imports = [
          ./nix/merger/mkHomeManagerOutputsMerge.nix
          treefmt-nix.flakeModule
          flake-root.flakeModule
          mission-control.flakeModule
          devshell.flakeModule
        ] ++ (builtins.attrValues flakeModules);


        # imports =
        #     [ # mergers
        #       ./nix/merger/mkHomeManagerOutputsMerge.nix
        #     ] ++
        #     [
        #   treefmt-nix.flakeModule
        #   flake-root.flakeModule
        #   mission-control.flakeModule
        #   devshell.flakeModule
        #   # sops-nix.nixosModules.sops
        #
        #   nixModules
        #   nixosModules
        #   homeixModules
        #   homeModules
        #   desktopEnvironment
        # ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];
      }
    )
  );

  # Imports
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-24.11";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    # flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    mission-control.url = "github:Platonic-Systems/mission-control";

    # NUR
    nur = {
      url = "github:nix-community/NUR";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    # utilities
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix.url = "github:Mic92/sops-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };

    # nixos-needsreboot = {
    #   url = "https://flakehub.com/f/thefossguy/nixos-needsreboot/*.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nix-darwin = {
    #   url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nix-index-database = {
    #   url = "github:Mic92/nix-index-database";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # vscode-server = {
    #   url = "github:nix-community/nixos-vscode-server";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nix-vscode-extensions = {
    #   url = "github:nix-community/nix-vscode-extensions";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # catppuccin = {
    #   url = "https://flakehub.com/f/catppuccin/nix/*";
    # };
    # catppuccin-vsc = {
    #   url = "https://flakehub.com/f/catppuccin/vscode/*";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    # kubectl = {
    #   url = "github:LongerHV/kubectl-overlay";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    # ghostty = {
    #   url = "github:ghostty-org/ghostty";
    # };
    # zen-browser = {
    #   url = "github:0xc000022070/zen-browser-flake";
    # };
    # nix-snapd = {
    #   url = "https://flakehub.com/f/io12/nix-snapd/*";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # quickemu = {
    #   url = "https://flakehub.com/f/quickemu-project/quickemu/*";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # quickgui = {
    #   url = "https://flakehub.com/f/quickemu-project/quickgui/*";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*";

    # neovim external plugins
    # nvim-plugin-vim-header = {
    #   url = "github:alpertuna/vim-header";
    #   flake = false;
    # };
    # nvim-plugin-blink-ripgrep = {
    #   url = "github:mikavilpas/blink-ripgrep.nvim";
    #   flake = false;
    # };
    # nvim-plugin-git-conflict = {
    #   url = "github:akinsho/git-conflict.nvim/v2.1.0";
    #   flake = false;
    # };
    # nvim-plugin-img-clip = {
    #   url = "github:HakonHarnes/img-clip.nvim/v0.6.0";
    #   flake = false;
    # };
    # nvim-plugin-godoc = {
    #   url = "github:fredrikaverpil/godoc.nvim/v2.3.0";
    #   flake = false;
    # };
    # nvim-plugin-other = {
    #   url = "github:rgroli/other.nvim";
    #   flake = false;
    # };
    # nvim-plugin-format-ts-errors = {
    #   url = "github:davidosomething/format-ts-errors.nvim";
    #   flake = false;
    # };
    # nvim-plugin-inc-rename = {
    #   url = "github:smjonas/inc-rename.nvim";
    #   flake = false;
    # };
  };
}
