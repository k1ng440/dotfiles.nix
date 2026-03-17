{ pkgs, ... }:
pkgs.writeShellScriptBin "noctalia-start" ''
  noctalia-shell
  while true; do
    noctalia-shell
    sleep 5
  done
''
