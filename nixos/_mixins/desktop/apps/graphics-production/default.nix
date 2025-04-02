{
  lib,
  pkgs,
  username,
  isInstall,
  isWorkstation,
  ...
}:
let
  installFor = [ "xenomorph" ];
in
lib.mkIf (lib.elem username installFor && isInstall && isWorkstation) {
  environment.systemPackages = with pkgs; [
    inkscape
  ];
}
