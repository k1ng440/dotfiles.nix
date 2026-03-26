{
  lib,
  config,
  ...
}:
{
  config =
    lib.mkIf
      (
        config ? "machine"
        && config.machine ? "computed"
        && config.machine ? "isMinimal"
        && !config.machine.computed.isMinimal
      )
      {
      };
}
