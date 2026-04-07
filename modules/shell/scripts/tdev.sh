#!/usr/bin/env bash
set -euo pipefail

SESSION_NAME="${1:-$(basename "$PWD")}"

find_free_port() {
    local port
    for _ in $(seq 1 20); do
        port=$((49152 + (RANDOM * 2 + RANDOM) % 16384))
        if ! ss -tln 2>/dev/null | awk '{print $4}' | grep -qE ":${port}$"; then
            echo "$port"
            return 0
        fi
    done
    echo "Error: could not find a free port after 20 attempts" >&2
    return 1
}

PORT=$(find_free_port)

PORT_FILE="/tmp/.opencode.port.$SESSION_NAME"
echo "$PORT" > "$PORT_FILE"

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    exec tmux attach -t "$SESSION_NAME"
fi

tmux new-session -d -s "$SESSION_NAME" -n dev "nvim ."

NVIM_PANE=$(tmux display-message -t "$SESSION_NAME:dev" -p '#{pane_id}')
tmux split-window -v -p 20 -t "$NVIM_PANE" # Terminal
tmux split-window -h -p 30 -t "$NVIM_PANE" "env OPENCODE_PORT=$PORT opencode --port $PORT" # opencode
tmux select-pane -t "$NVIM_PANE"
tmux attach -t "$SESSION_NAME"
rm -f "$PORT_FILE"
