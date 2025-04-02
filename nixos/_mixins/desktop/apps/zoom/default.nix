{
  lib,
  pkgs,
  username,
  ...
}:
let
  installFor = [ "xenomorph" ];
in
lib.mkIf (lib.elem username installFor) { environment.systemPackages = with pkgs; [ zoom-us ]; }
