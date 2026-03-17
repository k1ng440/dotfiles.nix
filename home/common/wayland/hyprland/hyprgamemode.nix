{
  pkgs,
  machine,
  kdegamemode ? null,
  ...
}:
pkgs.writeShellScriptBin "hyprgamemode" ''
  # Fallback to KDE if we are in Plasma
  ${pkgs.lib.optionalString (kdegamemode != null) ''
    if [ "''${XDG_CURRENT_DESKTOP:-}" = "KDE" ]; then
      exec "${kdegamemode}/bin/kdegamemode" "$@"
    fi
  ''}

  # Exit if not in Hyprland
  if [ "''${XDG_CURRENT_DESKTOP:-}" != "Hyprland" ]; then
    echo "Not in Hyprland or KDE, skipping gamemode scripts"
    exit 0
  fi

  # Use absolute paths for stable utilities, but NOT for noctalia-shell
  # to ensure we match the running session's instance.
  HYPRCTL="${pkgs.hyprland}/bin/hyprctl"

  export $(systemctl --user show-environment | xargs)

  gamemode_on() {
    ${pkgs.lib.optionalString (
      !machine.windowManager.hyprland.noctalia.enable
    ) "systemctl --user stop wallpaper-cycler.timer || true"}

    # Call noctalia-shell without an absolute path to use the session's version
    if ${pkgs.lib.optionalString machine.windowManager.hyprland.noctalia.enable "true"}; then
      if command -v noctalia-shell >/dev/null; then
        noctalia-shell ipc call powerProfile enableNoctaliaPerformance || echo "Noctalia IPC failed"
      fi
    fi

    "$HYPRCTL" --batch " \
      keyword animations:enabled 0; \
      keyword animation borderangle,0; \
      keyword decoration:shadow:enabled 0; \
      keyword decoration:blur:enabled 0; \
      keyword decoration:fullscreen_opacity 1; \
      keyword general:gaps_in 0; \
      keyword general:gaps_out 0; \
      keyword general:border_size 1; \
      keyword decoration:rounding 0"
    "$HYPRCTL" notify 1 5000 "rgb(40a02b)" "Gamemode [ON]"
  }

  gamemode_off() {
    ${pkgs.lib.optionalString (
      !machine.windowManager.hyprland.noctalia.enable
    ) "systemctl --user start wallpaper-cycler.timer || true"}

    if ${pkgs.lib.optionalString machine.windowManager.hyprland.noctalia.enable "true"}; then
      if command -v noctalia-shell >/dev/null; then
        noctalia-shell ipc call powerProfile disableNoctaliaPerformance || echo "Noctalia IPC failed"
      fi
    fi

    "$HYPRCTL" notify 1 5000 "rgb(d20f39)" "Gamemode [OFF]"
    "$HYPRCTL" reload
  }

  case "''${1:-}" in
    on) gamemode_on ;;
    off) gamemode_off ;;
    *)
      HYPRGAMEMODE=$("$HYPRCTL" getoption animations:enabled | awk 'NR==1{print $2}')
      if [ "$HYPRGAMEMODE" = 1 ]; then gamemode_on; else gamemode_off; fi
      ;;
  esac
''
