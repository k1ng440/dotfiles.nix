{ pkgs }:

pkgs.writeShellScriptBin "waybar-warp-status" ''
  if ! command -v warp-cli &> /dev/null; then
      echo '{"text": "WARP N/A", "class": "error", "tooltip": "warp-cli not found"}'
      exit 1
  fi


  STATUS=$(warp-cli status 2>/dev/null)

  if echo "$STATUS" | grep -q "Status update: Connected"; then
      ICON=""
      TEXT="WARP ON"
      CLASS="connected"
      TOOLTIP="Cloudflare WARP: Connected"
  elif echo "$STATUS" | grep -q "Status update: Disconnected"; then
      ICON=""
      TEXT="WARP OFF"
      CLASS="disconnected"
      TOOLTIP="Cloudflare WARP: Disconnected"
  elif echo "$STATUS" | grep -q "Status update: Connecting"; then
      ICON=""
      TEXT="WARP..."
      CLASS="connecting"
      TOOLTIP="Cloudflare WARP: Connecting"
  else
      ICON=""
      TEXT="WARP ??"
      CLASS="unknown"
      TOOLTIP="Cloudflare WARP: Unknown status"
  fi

  printf '{"text": "%s %s", "class": "%s", "tooltip": "%s"}\n' "$ICON" "$TEXT" "$CLASS" "$TOOLTIP"
''
