{
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devShells.default =
      pkgs.mkShell {inputsFrom = [config.mission-control.devShell];};
  };
}
