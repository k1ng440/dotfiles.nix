{
  description = "k1ng's NixOS, nix-darwin and Home Manager Configuration";

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      flake-root,
      home-manager,
      treefmt-nix,
      devshell,
      sops-nix,
      ...
    }:
    let
      lib = nixpkgs.lib;
      home-manager-lib = home-manager.lib;
      flake-parts-lib = flake-parts.lib;
      mylib = import ./nix/lib { lib = nixpkgs.lib; };
      rawNvimPlugins = mylib.filterInputsByPrefix { inherit (nixpkgs) lib; } "nvim-plugin-";
    in
    (flake-parts.lib.mkFlake
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
      }
      (
        {
          withSystem,
          moduleWithSystem,
          flake-parts-lib,
          ...
        }:
        let
          inherit (flake-parts-lib) importApply;

          flakeModules = {

            desktopEnvironment = importApply ./flake-modules/desktop-environment {
              localFlake = self;
              inherit withSystem;
            };
            nixosCommon = importApply ./flake-modules/nixos-common {
              localFlake = self;
              inherit withSystem;
            };
            nixos = importApply ./nixos {
              localFlake = self;
              inherit withSystem;
            };
            nixModules = importApply ./nix {
              localFlake = self;
              inherit withSystem;
            };
            virtualisation = importApply ./flake-modules/virtualisation {
              localFlake = self;
              inherit withSystem;
            };
            homeConfiguratiions = importApply ./home {
              localFlake = self;
              inherit withSystem moduleWithSystem rawNvimPlugins;
            };
          };
        in
        {
          # Debug: https://flake.parts/debug.html
          debug = true;
          imports = [
            ./nix/merger/mkHomeManagerOutputsMerge.nix
            ./flake-modules/home-manager/flake-module.nix
            treefmt-nix.flakeModule
            flake-root.flakeModule
            devshell.flakeModule
            ./nix/formatter.nix
          ] ++ (builtins.attrValues flakeModules);

          flake = {
            nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
          };

          systems = [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ];
        }
      )
    );

  /**
      ***********************************
      ***********************************
      ************ IMPORTS **************
      ***********************************
      ***********************************
    *
  */
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    stub-flake.url = "github:k1ng440/stub-flake"; # A completely empty flake
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    # NUR
    nur = {
      url = "github:nix-community/NUR";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };


    stylix.url = "github:danth/stylix";

    # utilities
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        darwin.follows = "stub-flake";
        home-manager.follows = "home-manager";
      };
    };
    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs = {
        treefmt-nix.follows = "treefmt-nix";
        devshell.follows = "devshell";
        hyprland.follows = "stub-flake";
        home-manager.follows = "stub-flake";
      };
    };

    # nixos-needsreboot = {
    #   url = "https://flakehub.com/f/thefossguy/nixos-needsreboot/*.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nix-darwin = {
    #   url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    # nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*";

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
}
