{ pkgs, ... }:
pkgs.writeShellScriptBin "noctalia-start" ''
  uwsm app -- noctalia-shell
  while true; do
    uwsm app -- noctalia-shell
    sleep 5
  done
''
