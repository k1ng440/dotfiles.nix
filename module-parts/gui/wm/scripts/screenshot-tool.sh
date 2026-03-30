#!/bin/bash
OPTION_CLIPBOARD="Copy to Clipboard"
OPTION_PIN="Pin"
OPTION_SAVE="Save"
OPTION_EDIT="Annotate (Satty)"
OPTION_OCR="OCR to Clipboard"
OPTION_UPLOAD="Upload & Copy URL"
PROMPT="Select Screenshot Action"
ENABLE_FREEZE=true
HIDE_CURSOR=true
TMPFILE=""
MODE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --mode=*)
            MODE="${1#--mode=}"
            shift
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

notify() {
    local message="$1"
    notify-send --app-name "screenshot" -u normal "$message"
}

init_tempfile() {
    TMPFILE=$(mktemp --suffix=.png)
}

cleanup() {
    rm -f "$TMPFILE"
    if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null || kill -9 "$PID" 2>/dev/null
    fi
}
trap cleanup EXIT

freeze_screen() {
    if [ "$ENABLE_FREEZE" = true ]; then
        local args=()
        if [ "$HIDE_CURSOR" = true ]; then
            args+=(--hide-cursor)
        fi
        wayfreeze "${args[@]}" &
        PID=$!
        sleep 0.1
    fi
}

unfreeze_screen() {
    if [ "$ENABLE_FREEZE" = true ] && [ -n "${PID:-}" ]; then
        kill "$PID" 2>/dev/null
        local i=0
        while kill -0 "$PID" 2>/dev/null && [ $i -lt 10 ]; do
            sleep 0.1
            i=$((i + 1))
        done
        if kill -0 "$PID" 2>/dev/null; then
            kill -9 "$PID" 2>/dev/null
            notify "wayfreeze had to be force killed ⚠️"
        fi
        trap - EXIT
    fi
}

capture_screenshot() {
    freeze_screen
    if grim -g "$(slurp -d)" "$TMPFILE"; then
        unfreeze_screen
        return 0
    else
        unfreeze_screen
        notify "Capture failed ❌"
        cleanup
        return 1
    fi
}

show_menu() {
    printf "%s\n%s\n%s\n%s\n%s\n%s" \
        "$OPTION_CLIPBOARD" \
        "$OPTION_EDIT" \
        "$OPTION_OCR" \
        "$OPTION_UPLOAD" \
        "$OPTION_PIN" \
        "$OPTION_SAVE" | rofi -dmenu -p "$PROMPT" -cache-file /dev/null
}

handle_choice() {
    case "$1" in
    "$OPTION_CLIPBOARD"|clipboard)
        if wl-copy --type image/png <"$TMPFILE"; then
            notify "Image copied to clipboard 📋"
        else
            notify "Failed to copy image to clipboard ❌"
        fi
        ;;
    "$OPTION_PIN"|pin)
        imv "$TMPFILE"
        ;;
    "$OPTION_SAVE"|save)
        local timestamp
        timestamp=$(date '+%Y%m%d_%H%M%S')
        local savepath="$HOME/Pictures/screenshot/Screenshot_${timestamp}.png"
        mkdir -p "$(dirname "$savepath")"
        if mv "$TMPFILE" "$savepath"; then
            notify "Saved to $savepath 📁"
            TMPFILE=""
        else
            notify "Failed to save screenshot ❌"
            cleanup
        fi
        ;;
    "$OPTION_EDIT"|edit)
        if satty --filename "$TMPFILE" --output-filename "$TMPFILE"; then
            notify "Annotation saved ✏️"
        else
            notify "Annotation cancelled or failed ❌"
        fi
        ;;
    "$OPTION_OCR"|ocr)
        local text
        text=$(tesseract "$TMPFILE" stdout 2>/dev/null)
        if [ -n "$text" ]; then
            echo "$text" | wl-copy
            notify "Text copied to clipboard 🔍"
        else
            notify "No text detected ❌"
        fi
        ;;
    "$OPTION_UPLOAD"|upload)
        local url
        url=$(curl -s -F "reqtype=fileupload" -F "userhash=" -F "fileToUpload=@$TMPFILE" https://catbox.moe/user/api.php | tr -d '[:space:]')
        if [ -n "$url" ]; then
            echo "$url" | wl-copy
            notify "Uploaded — URL copied to clipboard 🔗 $url"
        else
            notify "Upload failed ❌"
        fi
        ;;
    *)
        notify "Operation cancelled 🚫"
        ;;
    esac
}

init_tempfile
if capture_screenshot; then
    if [ -n "$MODE" ]; then
        handle_choice "$MODE"
    else
        choice=$(show_menu)
        handle_choice "$choice"
    fi
else
    exit 1
fi

if [ -n "$TMPFILE" ] && [ -f "$TMPFILE" ]; then
    cleanup
fi
