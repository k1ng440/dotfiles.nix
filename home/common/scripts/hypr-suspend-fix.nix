{ pkgs, ... }:

pkgs.writeShellScriptBin "hypr-suspend-fix" ''
  if [ "$1" = "pre" ]; then
      ${pkgs.procps}/bin/pkill -f -STOP Hyprland || true
  elif [ "$1" = "post" ]; then
      ${pkgs.procps}/bin/pkill -f -CONT Hyprland || true
      ${pkgs.hyprland}/bin/hyprctl dispatch dpms on || true
  fi
''
