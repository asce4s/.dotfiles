#!/usr/bin/env bash
# Listen on Hyprland socket2 for monitor hotplug events and re-apply the
# monitor profile with a short debounce to let the kernel settle.

APPLY_SCRIPT="${HOME}/.config/hypr/scripts/apply-monitor-profile.sh"
DEBOUNCE_SECS=1

# Wait for the Hyprland socket to appear (boot race)
for i in $(seq 1 30); do
    SOCK="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
    [[ -S "$SOCK" ]] && break
    sleep 0.5
done

if [[ ! -S "$SOCK" ]]; then
    echo "watch-monitors: socket not found after 15s, giving up" >&2
    exit 1
fi

debounce_pid=""

handle_event() {
    local event="$1"
    case "$event" in
        monitoradded*|monitorremoved*)
            # Cancel any pending debounce
            if [[ -n "$debounce_pid" ]] && kill -0 "$debounce_pid" 2>/dev/null; then
                kill "$debounce_pid" 2>/dev/null
            fi
            # Schedule apply after debounce period
            ( sleep "$DEBOUNCE_SECS" && bash "$APPLY_SCRIPT" ) &
            debounce_pid=$!
            ;;
    esac
}

# Tail the event stream indefinitely
nc -U "$SOCK" | while IFS= read -r line; do
    handle_event "$line"
done
