#!/bin/bash
# Toggle GIF capture. First run starts recording, second run stops and
# converts the clip into a gif.

PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/gif-tool.pid"
VIDFILE="${XDG_RUNTIME_DIR:-/tmp}/gif-tool.vid"
TMPDIR_CAP="/tmp/gif-tool"
LOG="$TMPDIR_CAP/gif-tool.log"
OUTDIR="$HOME/Pictures/Gifs"
FPS=30

notify() {
    notify-send --app-name "gif-tool" -u normal "$1"
}

kill_recorder() {
    local pid="$1"

    kill -INT "$pid" 2>/dev/null
    for _ in $(seq 1 20); do
        kill -0 "$pid" 2>/dev/null || return 0
        sleep 0.1
    done

    kill -TERM "$pid" 2>/dev/null
    for _ in $(seq 1 20); do
        kill -0 "$pid" 2>/dev/null || return 0
        sleep 0.1
    done

    kill -KILL "$pid" 2>/dev/null
    return 0
}

stop_recording() {
    local pid="$1"
    local vid="$2"

    kill_recorder "$pid"

    mkdir -p "$OUTDIR"
    local out
    out="$OUTDIR/$(date +%Y-%m-%dT%H:%M:%S%z).gif"
    notify "Converting to gif…"
    if gifski --fps 15 --width 1000 --quality 80 -o "$out" "$vid"; then
        notify "Gif saved: $out"
    else
        notify "Gif conversion failed"
    fi

    rm -f "$PIDFILE" "$VIDFILE" "$LOG"
    rm -f "$vid"
}

if [[ -f "$PIDFILE" ]]; then
    pid="$(cat "$PIDFILE")"
    vid="$(cat "$VIDFILE")"

    if kill -0 "$pid" 2>/dev/null; then
        stop_recording "$pid" "$vid"
    else
        notify "Recorder died unexpectedly. Log: $LOG"
        rm -f "$PIDFILE" "$VIDFILE" "$vid"
    fi
else
    mkdir -p "$TMPDIR_CAP"

    wayfreeze --hide-cursor &
    freeze_pid=$!
    sleep 0.1

    region="$(slurp -f "%wx%h+%x+%y")"
    slurp_status=$?
    kill "$freeze_pid" 2>/dev/null

    if [ "$slurp_status" -ne 0 ] || [ -z "$region" ]; then
        notify "Selection cancelled"
        exit 0
    fi

    vid="$TMPDIR_CAP/$(date +%s).mp4"
    gpu-screen-recorder -w "$region" -f "$FPS" -fallback-cpu-encoding yes -o "$vid" >"$LOG" 2>&1 &
    echo "$!" >"$PIDFILE"
    echo "$vid" >"$VIDFILE"

    sleep 1
    if ! kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
        notify "Recorder failed to start. Log: $LOG"
        rm -f "$PIDFILE" "$VIDFILE" "$vid"
        exit 1
    fi

    notify "Recording started. Press Mod+D menu → g to stop."
fi
