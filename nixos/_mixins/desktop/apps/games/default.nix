{
  inputs,
  isInstall,
  isWorkstation,
  lib,
  pkgs,
  platform,
  username,
  ...
}:
let
  installFor = [ "none" ];
in
lib.mkIf (lib.elem username installFor && isInstall && isWorkstation) {
  environment = {
    systemPackages = [
      pkgs.steamguard-cli
      pkgs.protonup-qt
      pkgs.protonplus
    ];
  };
}
