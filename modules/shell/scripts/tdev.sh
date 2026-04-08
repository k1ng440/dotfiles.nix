#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$PWD"
SESSION_NAME="${1:-$(basename "$TARGET_DIR")}"

if tmux has-session -t "=$SESSION_NAME" 2>/dev/null; then
  echo "Session '$SESSION_NAME' already exists. Attaching..."
  exec tmux attach-session -t "=$SESSION_NAME"
fi

trap 'if tmux has-session -t "=$SESSION_NAME" 2>/dev/null; then tmux kill-session -t "=$SESSION_NAME"; fi; exit 1' ERR

PORT=$(ss -tln | awk '{print $4}' | grep -oE '[0-9]+$' | sort -n | awk 'BEGIN{p=49152} {if($1==p) p++} END{print p}')
NVIM_PANE=$(tmux new-session -d -s "$SESSION_NAME" -n dev -e "OPENCODE_PORT=$PORT" -P -F "#{pane_id}" "nvim .; exec $SHELL")
tmux select-pane -t "$NVIM_PANE" -T "Editor"

OPENCODE_PANE=$(tmux split-window -h -p 20 -t "$NVIM_PANE" -P -F "#{pane_id}" "opencode --port $PORT; exec $SHELL")
tmux select-pane -t "$OPENCODE_PANE" -T "Opencode"

# TERM_PANE=$(tmux split-window -v -p 20 -t "$NVIM_PANE" -P -F "#{pane_id}")
# tmux select-pane -t "$TERM_PANE" -T "Terminal"

tmux new-window -t "$SESSION_NAME" -n terminal -c "$TARGET_DIR"

trap - ERR

tmux select-window -t "$SESSION_NAME:dev"
tmux select-pane -t "$NVIM_PANE"
tmux attach-session -t "$SESSION_NAME"
