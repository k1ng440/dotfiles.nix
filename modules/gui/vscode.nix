_: {
  perSystem =
    { pkgs, ... }:
    let
      inherit (pkgs.vscode-utils) buildVscodeMarketplaceExtension;

      mkExtension = mktplcRef: buildVscodeMarketplaceExtension { inherit mktplcRef; };

      marketplaceExtensions = [
        (mkExtension {
          name = "qt-core";
          publisher = "TheQtCompany";
          version = "1.11.1";
          hash = "sha256-PQmNWezNYVGGNFAJrlMRhXHe3o0XV6LxE2omU1mqZM0=";
        })
        (mkExtension {
          name = "qt-qml";
          publisher = "TheQtCompany";
          version = "1.11.1";
          hash = "sha256-lUXx2VAXK0Av4T3bRW7hXpP0u7zJbDvMbKkpPACT4WE=";
        })
      ];

      nixpkgsExtensions = with pkgs.vscode-extensions; [
        # Appearance
        enkia.tokyo-night
        pkief.material-icon-theme

        # Editor enhancements
        aaron-bond.better-comments
        gruntfuggly.todo-tree
        usernamehw.errorlens
        formulahendry.auto-rename-tag
        vscodevim.vim

        # Formatting & linting
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint

        # Git
        donjayamanne.githistory
        eamodio.gitlens
        mhutchie.git-graph

        # Web / JS / TS
        bradlc.vscode-tailwindcss
        christian-kohler.npm-intellisense
        graphql.vscode-graphql-syntax

        # Nix
        jnoortheen.nix-ide
        mkhl.direnv

        # Python
        ms-python.python
        ms-python.vscode-pylance
        ms-python.black-formatter
        ms-python.flake8

        # Go
        golang.go

        # Rust
        rust-lang.rust-analyzer
        tamasfe.even-better-toml

        # Other languages
        denoland.vscode-deno
        sumneko.lua
        xadillax.viml
        prisma.prisma
        yzhang.markdown-all-in-one
      ];
    in
    {
      packages.vscodium = pkgs.vscode-with-extensions.override {
        vscode = pkgs.vscodium;
        vscodeExtensions = nixpkgsExtensions ++ marketplaceExtensions;
      };
    };

  flake.modules.nixos.gui =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: _prev: {
          inherit (pkgs.custom) vscodium;
        })
      ];
      environment.systemPackages = with pkgs; [ vscodium ];
      custom.persist = {
        home.directories = [
          ".config/VSCodium"
          ".vscode-oss"
        ];
      };
    };
}
