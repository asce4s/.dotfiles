#!/bin/bash
# Switch keyboard layouts configured in ~/.config/hypr/config.lua (kbLayouts)

layout_file="${HOME}/.cache/kb_layout"
notif_icon="${HOME}/.config/swaync/images/ja.png"

ignore_patterns=(
	"(avrcp)"
	"Bluetooth Speaker"
)

get_layouts() {
	hyprctl getoption input:kb_layout 2>/dev/null | awk 'NR==1 {print $2}' | tr -d ' '
}

get_keyboards() {
	hyprctl devices -j 2>/dev/null | jq -r '.keyboards[].name'
}

is_ignored() {
	local device_name="$1"
	for pattern in "${ignore_patterns[@]}"; do
		if [[ "$device_name" == *"$pattern"* ]]; then
			return 0
		fi
	done
	return 1
}

layouts_csv="$(get_layouts)"
IFS=',' read -r -a layout_mapping <<< "$layouts_csv"
layout_count=${#layout_mapping[@]}

if (( layout_count == 0 )); then
	notify-send -u low -t 2000 "kb_layout" " Error:" " No layouts configured"
	exit 1
fi

if [[ ! -f "$layout_file" ]]; then
	echo "${layout_mapping[0]}" > "$layout_file"
fi

current_layout="$(cat "$layout_file")"
current_index=0

for ((i = 0; i < layout_count; i++)); do
	if [[ "$current_layout" == "${layout_mapping[i]}" ]]; then
		current_index=$i
		break
	fi
done

next_index=$(( (current_index + 1) % layout_count ))
new_layout="${layout_mapping[next_index]}"

if (( layout_count == 1 )); then
	notify-send -u low -i "$notif_icon" " kb_layout: $new_layout"
	echo "$new_layout" > "$layout_file"
	exit 0
fi

error_found=false
while read -r name; do
	[[ -z "$name" ]] && continue
	if is_ignored "$name"; then
		continue
	fi
	if ! hyprctl switchxkblayout "$name" "$next_index" >/dev/null 2>&1; then
		error_found=true
	fi
done <<< "$(get_keyboards)"

if [[ "$error_found" == true ]]; then
	notify-send -u low -t 2000 "kb_layout" " Error:" " Layout change failed"
	exit 1
fi

notify-send -u low -i "$notif_icon" " kb_layout: $new_layout"
echo "$new_layout" > "$layout_file"
