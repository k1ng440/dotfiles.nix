{
  description = "k1ng's NixOS, nix-darwin and Home Manager Configuration";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "24.11";
      helper = import ./lib { inherit inputs outputs stateVersion; };
      rawNvimPlugins = helper.filterInputsByPrefix { inherit (nixpkgs) lib; } "nvim-plugin-";
    in
    {
      # home-manager build --flake $HOME/nix-config -L
      # home-manager switch -b backup --flake $HOME/nix-config
      # nix run nixpkgs#home-manager -- switch -b backup --flake "${HOME}/nix-config"
      homeConfigurations = {
        "nixos@iso-console" = helper.mkHome {
          hostname = "iso-console";
          username = "nixos";
        };
        # "nixos@iso-lomiri" = helper.mkHome {
        #   hostname = "iso-lomiri";
        #   username = "nixos";
        #   desktop = "lomiri";
        # };
        # "nixos@iso-pantheon" = helper.mkHome {
        #   hostname = "iso-pantheon";
        #   username = "nixos";
        #   desktop = "pantheon";
        # };
        # "nixos@iso-i3" = helper.mkHome {
        #   hostname = "iso-i3";
        #   username = "nixos";
        #   desktop = "i3";
        # };

        # Workstations
        "k1ng@xenomorph" = helper.mkHome {
          hostname = "phasma";
          desktop = "hyprland";
        };
        "k1ng@rog-laptop" = helper.mkHome {
          hostname = "vader";
          desktop = "hyprland";
        };
      };

      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-pantheon|iso-i3}.config.system.build.isoImage
        iso-console = helper.mkNixos {
          hostname = "iso-console";
          username = "nixos";
          hostId = "9a38c14e";
        };

        # iso-lomiri = helper.mkNixos {
        #   hostname = "iso-lomiri";
        #   username = "nixos";
        #   desktop = "lomiri";
        # };
        # iso-pantheon = helper.mkNixos {
        #   hostname = "iso-pantheon";
        #   username = "nixos";
        #   desktop = "pantheon";
        # };
        # iso-i3 = helper.mkNixos {
        #   hostname = "iso-i3";
        #   username = "nixos";
        #   desktop = "i3";
        # };
        # Workstations
        #  - sudo nixos-rebuild boot --flake $HOME/nix-config
        #  - sudo nixos-rebuild switch --flake $HOME/nix-config
        #  - nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel
        #  - nix run github:nix-community/nixos-anywhere -- --flake '.#{hostname}' root@{ip-address}
        xenomorph = helper.mkNixos {
          hostname = "xenomorph";
          desktop = "hyprland";
          hostId = "4f8d7f6f";
        };
      };

      #nix run nix-darwin -- switch --flake ~/nix-config
      #nix build .#darwinConfigurations.{hostname}.config.system.build.toplevel
      darwinConfigurations = {
        # examplehost = helper.mkDarwin {
        #   hostname = "examplehost";
        #   # platform = "x86_64-darwin";
        # };
      };

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Custom NixOS modules
      nixosModules = import ./modules/nixos;
      # Custom packages; acessible via 'nix build', 'nix shell', etc

      # packages = flake-utils.lib.eachSystem (helper.supportedSystems) (
      #   system:
      #   let
      #     pkgs = nixpkgs.legacyPackages.${system};
      #     isoDotfilesLocation = builtins.toPath "/boot/dotfiles";
      #     actualIsoDotfilesLocation = (builtins.toPath "/iso${isoDotfilesLocation}");
      #     mntDotfilesLocation = (builtins.toPath "/mnt") + "/random";
      #   in
      #   {
      #
      #     installers = inputs.nixos-generators.nixosGenerate {
      #       system = system;
      #       specialArgs = {
      #         pkgs = pkgs;
      #       };
      #       customFormats = {
      #         nix-live-iso = {
      #           imports = [
      #             "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      #           ];
      #
      #           isoImage = {
      #             squashfsCompression = "zstd -Xcompression-level 3";
      #             contents = [
      #               {
      #                 source = ../..;
      #                 target = isoDotfilesLocation;
      #               }
      #             ];
      #           };
      #
      #           # override installation-cd-base and enable wpa and sshd start at boot
      #           systemd.services.wpa_supplicant.wantedBy = nixpkgs.lib.mkForce [ "multi-user.target" ];
      #
      #           systemd.services.sshd.wantedBy = nixpkgs.lib.mkForce [ "multi-user.target" ];
      #           users.users.root.openssh.authorizedKeys.keys = [
      #             "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqMh6k4NRNF4MzW/RYXlQ2FzFHkDE3rL3UuWT91ZzYK6oybFW2dXugxxHXA0a5d6jU4sToBB0zYLqCyCfb0rEJ+ukN0LIC+IJ2MVb7b7WSJyju0PeJqri1tice2quZO8C27rbYEMa1QgpUapDhEuNfFnDkXzkr0NnxOs2vwOdnGRm3VF1FRaV/0xmmJDeh8GmHdj40StH/UtNU63YvsTY1DJHb6Tw3O0hY4cvxx3z3SZv18bDDfn6EA/47Ao6BO88bT/b3qhmoQc55ESWX5siUk4/BtgEgQNuqZm8rxhRmW4NqdsWbLIwHdJCVn51DwokykP1A9x1QEAQRw5yqRy0fQ== rsa-key-20151130"
      #           ];
      #
      #           formatAttr = "isoImage";
      #           fileExtension = ".iso";
      #         };
      #       };
      #
      #       format = "nix-live-iso";
      #     };
      #   }
      # );

      # Formatter for .nix files, available via 'nix fmt'
      formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
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
      url = "github:Mic92/nix-index-database";
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
    catppuccin = {
      url = "https://flakehub.com/f/catppuccin/nix/*";
    };
    catppuccin-vsc = {
      url = "https://flakehub.com/f/catppuccin/vscode/*";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    kubectl = {
      url = "github:LongerHV/kubectl-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
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
    nix-snapd = {
      url = "https://flakehub.com/f/io12/nix-snapd/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickemu = {
      url = "https://flakehub.com/f/quickemu-project/quickemu/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickgui = {
      url = "https://flakehub.com/f/quickemu-project/quickgui/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*";

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
