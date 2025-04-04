{
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    inherit (config.mission-control) installToDevShell;
    inherit (pkgs) mkShellNoCC;
  in {
    devShells.default = installToDevShell (mkShellNoCC {
      name = "setting-up-machines-nix-style";
      packages = with pkgs; [
        # Add your custom packages
      ];
    });
  };
}
