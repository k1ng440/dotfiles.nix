{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    {
      inputs',
      pkgs,
      lib,
      config,
      ...
    }:
    {
      treefmt = {
        inherit (config.flake-root) projectRootFile;
        programs.nixfmt.enable = true;
        programs.nixfmt.width = 100;

        programs.shellcheck.enable = false;
      };

      formatter = config.treefmt.build.wrapper;
    };
}
