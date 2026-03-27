{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages =
          with pkgs;
          [
            age
            sops
            cachix
            deadnix
            # FIXME: remove on new release of statix
            (statix.overrideAttrs (_o: rec {
              src = fetchFromGitHub {
                owner = "oppiliappan";
                repo = "statix";
                rev = "43681f0da4bf1cc6ecd487ef0a5c6ad72e3397c7";
                hash = "sha256-LXvbkO/H+xscQsyHIo/QbNPw2EKqheuNjphdLfIZUv4=";
              };

              cargoDeps = pkgs.rustPlatform.importCargoLock {
                lockFile = src + "/Cargo.lock";
                allowBuiltinFetchGit = true;
              };
            }))
            nil
            nixd
            nixfmt
            pre-commit
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
