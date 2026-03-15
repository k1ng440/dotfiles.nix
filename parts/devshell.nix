{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      devShells.default = import ../shell.nix {
        inherit pkgs;
        checks = inputs.self.checks.${system};
      };
    };
}
