{
  isInstall,
  isWorkstation,
  lib,
  pkgs,
  username,
  ...
}:
let
  installFor = [ "none" ];
in
lib.mkIf (lib.elem username installFor && isInstall && isWorkstation) {
  environment = {
    systemPackages = [
    ];
  };
}
