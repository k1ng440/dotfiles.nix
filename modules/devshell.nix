{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages =
          with pkgs;
          [
            go
            gopls
            gotools
            age
            sops
            cachix
            deadnix
            statix
            nil
            nixd
            nixfmt
            pre-commit
            nvfetcher
          ]
          ++ [
            wlr-randr # used to get display info
          ];

        env = {
          # Required by rust-analyzer
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };

        nativeBuildInputs = with pkgs; [
          cargo
          rustc
          rust-analyzer
          rustfmt
          clippy
          pkg-config
        ];

        buildInputs = with pkgs; [
          pre-commit
          glib
          gexiv2 # for reading metadata
        ];
      };
    };
}
