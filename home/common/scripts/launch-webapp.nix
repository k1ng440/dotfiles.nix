{ pkgs }:
pkgs.writeShellScriptBin "launch-webapp" ''
  # Launch the passed in URL as a web app in the default browser (or chromium if the default doesn't support --app).

  browser=$(xdg-settings get default-web-browser)

  case "$browser" in
    google-chrome* | brave-browser* | microsoft-edge* | opera* | vivaldi* | helium*) ;;
    *) browser="chromium.desktop" ;;
  esac

  # Build path list from XDG_DATA_DIRS
  IFS=: read -ra ADIRS <<< "$XDG_DATA_DIRS"
  SEARCH_PATHS=()
  for dir in "''${ADIRS[@]}"; do
    SEARCH_PATHS+=("$dir/applications/$browser")
  done

  EXEC_CMD=$(sed -n 's/^Exec=\([^ ]*\).*/\1/p' "''${SEARCH_PATHS[@]}" 2>/dev/null | head -1)

  if [[ -z "$EXEC_CMD" ]]; then
      # Fallback if desktop file not found
      EXEC_CMD="chromium"
  fi

  exec setsid uwsm-app -- "$EXEC_CMD" --app="$1" "''${@:2}"
''
