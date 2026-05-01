#!/usr/bin/env bash
# Apply the correct Hyprland monitor profile based on DRM connector status.
# Reads /sys/class/drm/card*-<NAME>/status for each output, selects a profile,
# points ~/.config/hypr/profile-active at the right directory, then reloads.

set -euo pipefail

HYPR_DIR="${HOME}/.config/hypr"
PROFILES_DIR="${HYPR_DIR}/profiles"
ACTIVE_LINK="${HYPR_DIR}/profile-active"
STATE_FILE="/tmp/hypr-monitor-profile"

# ── connector detection ─────────────────────────────────────────────────────
drm_status() {
    local name="$1"
    local path
    path=$(echo /sys/class/drm/card*-"${name}"/status 2>/dev/null | head -n1)
    [[ -f "$path" ]] && cat "$path" || echo "disconnected"
}

edp_status=$(drm_status "eDP-1")
dp_status=$(drm_status "DP-1")
hdmi_status=$(drm_status "HDMI-A-1")

dp_on=false
hdmi_on=false
[[ "$dp_status"   == "connected" ]] && dp_on=true
[[ "$hdmi_status" == "connected" ]] && hdmi_on=true

# ── profile selection ───────────────────────────────────────────────────────
if $dp_on && $hdmi_on; then
    profile="docked"
    monitors_src=""
    workspace_src=""
elif ! $dp_on && ! $hdmi_on; then
    profile="laptop"
    monitors_src=""
    workspace_src=""
elif $dp_on; then
    profile="external_only"
    monitors_src="${PROFILES_DIR}/external_only/monitors-dp.conf"
    workspace_src="${PROFILES_DIR}/external_only/workspace-rules-dp.conf"
else
    profile="external_only"
    monitors_src="${PROFILES_DIR}/external_only/monitors-hdmi.conf"
    workspace_src="${PROFILES_DIR}/external_only/workspace-rules-hdmi.conf"
fi

# ── idempotency check ───────────────────────────────────────────────────────
prev_state=""
[[ -f "$STATE_FILE" ]] && prev_state=$(cat "$STATE_FILE")

# For external_only the exact sub-variant matters too
state_key="${profile}:${monitors_src}"

if [[ "$state_key" == "$prev_state" ]]; then
    exit 0
fi

# ── update external_only symlinks inside the profile dir ────────────────────
if [[ "$profile" == "external_only" ]]; then
    ln -sf "$monitors_src"  "${PROFILES_DIR}/external_only/monitors.conf"
    ln -sf "$workspace_src" "${PROFILES_DIR}/external_only/workspace-rules.conf"
fi

# ── point profile-active at the chosen profile ──────────────────────────────
ln -sfn "${PROFILES_DIR}/${profile}" "${ACTIVE_LINK}"

# ── persist state & reload ──────────────────────────────────────────────────
echo "$state_key" > "$STATE_FILE"

hyprctl reload
