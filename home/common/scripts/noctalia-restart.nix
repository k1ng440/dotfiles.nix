{ pkgs }:
pkgs.writeShellScriptBin "noctalia-restart" ''
  pkill noctalia-shell
  sleep 1
  (noctalia-shell &)
  disown
  echo "Restarted noctalia-shell"
''
