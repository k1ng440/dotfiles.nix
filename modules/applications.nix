{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (!config.machine.computed.isMinimal) {
    programs.appimage.binfmt = true;
    programs.nix-ld.enable = true;
  };
}
