{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {
    inputs',
    pkgs,
    lib,
    config,
    ...
  }: {
    treefmt = {
      inherit (config.flake-root) projectRootFile;
      programs.alejandra.enable = true;
      programs.alejandra.package = inputs'.nixpkgs-unstable.legacyPackages.alejandra;

      programs.nixfmt.enable = false;
      programs.nixfmt.package = pkgs.nixfmt;

      programs.shellcheck.enable = false;
    };

    formatter = config.treefmt.build.wrapper;
  };
}
