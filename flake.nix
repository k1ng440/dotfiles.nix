{
  description = "k1ng's NixOS, nix-darwin and Home Manager Configuration";

  outputs =
    inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      stateVersion = "24.11"; # Do not change
      inherit (self) outputs;

      lib = nixpkgs.lib.extend (
        self: super: {
          custom = import ./lib {
            inherit inputs stateVersion outputs;
            inherit (nixpkgs) lib;
          };
        }
      );

      system = "x86_64-linux";
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      pkgs = {
        x86_64-linux = rec {
          system = "x86_64-linux";
          stable = nixpkgs.legacyPackages.${system}.extend (final: prev: {
            config = prev.config // {
              allowUnfree = true;
            };
          });
          unstable = nixpkgs-unstable.legacyPackages.${system}.extend (final: prev: {
            config = prev.config // {
              allowUnfree = true;
            };
          });
        };
      };

      forAllSystems = lib.genAttrs systems;
    in
      {

      /**
        NixOS Configurations *
      */
      nixosConfigurations = {
        xenomorph = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs lib;
            unstable = pkgs.x86_64-linux.unstable;
            stable = pkgs.x86_64-linux.stable;
            hostname = "xenomorph";
            username = "k1ng";
            profile = "nvidia";
          };
          modules = [
            # inputs.home-manager.nixosModules.home-manager
            # {
            #   home-manager.useGlobalPkgs = true;
            #   home-manager.useUserPackages = true;
            #   home-manager.users.k1ng = import ../home;
            #   home-manager.extraSpecialArgs = {
            #     inherit inputs;
            #   };
            # }
            ./profiles/xenomorph
          ];
        };
      };

      /**
        Home Manager Configurations
      */
      homeConfigurations = {
        "k1ng@xenomorph" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs.x86_64-linux.stable;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
          modules = [
            {
              home = {
                username = "k1ng";
                homeDirectory = "/home/k1ng";
                stateVersion = "24.11";
              };
            }
            ./home
          ];
        };
      };

      /**
        Formatter
      */
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };

  /**
IMPORTS
*/
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    stub-flake.url = "github:k1ng440/stub-flake"; # A completely empty flake
    hyprland = {
      url = "github:hyprwm/Hyprland";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # Theme
    stylix.url = "github:danth/stylix/release-24.11";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    catppuccin.url = "https://flakehub.com/f/catppuccin/nix/*";

    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
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
    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs = {
        devshell.follows = "devshell";
        hyprland.follows = "stub-flake";
        home-manager.follows = "stub-flake";
      };
    };
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
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

    # Personal Repositories
    # Authenticate via ssh and use shallow clone
    nix-secrets = {
      url = "git+ssh://git@gitlab.com/k1ng4401/nix-secrets.git?ref=main&shallow=1";
      inputs = { };
    };
  };
}
