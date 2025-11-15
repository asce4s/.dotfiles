#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Wallpaper Picker

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Wallpaper directory - change this to your wallpaper location
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"

# Config directory for storing wallpaper state
CONFIG_DIR="$HOME/.config/rofi/applets"

# Hyprland shared directory for symlink
HYPR_SHARED_DIR="$HOME/.config/hypr/hypr_shared"

# Create directories if they don't exist
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    mkdir -p "$WALLPAPER_DIR"
fi

if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir -p "$CONFIG_DIR"
fi

if [[ ! -d "$HYPR_SHARED_DIR" ]]; then
    mkdir -p "$HYPR_SHARED_DIR"
fi

# Theme Elements
prompt='Wallpaper'
mesg="DIR: $WALLPAPER_DIR"

if [[ "$theme" == *'type-1'* ]]; then
	list_col='1'
	list_row='6'
	win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
	list_col='1'
	list_row='6'
	win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
	list_col='1'
	list_row='6'
	win_width='520px'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
	list_col='6'
	list_row='1'
	win_width='670px'
fi

# Options
layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
	option_1="󰸉 Select Wallpaper"
	option_2=" Random Wallpaper"
	option_3=" Previous Wallpaper"
	option_4=" Next Wallpaper"
	option_5=" Favorite Wallpaper"
	option_6=" Open Wallpaper Dir"
else
	option_1="󰸉"
	option_2=""
	option_3=""
	option_4=""
	option_5=""
	option_6=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "󰸉";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Notification function with fallback
notify_user() {
	local message="$1"
	notify-send "Wallpaper" "$message"
}

# Get list of wallpapers
get_wallpapers() {
	find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.webp" \) 2>/dev/null
}

# Select wallpaper using rofi with image previews
select_wallpaper() {
	local wallpapers=()
	local wallpaper_paths=()
	
	while IFS= read -r wallpaper; do
		wallpaper_paths+=("$wallpaper")
		wallpapers+=("$(basename "$wallpaper")")
	done < <(get_wallpapers | sort)
	
	if [[ ${#wallpapers[@]} -eq 0 ]]; then
		notify_user "No wallpapers found in $WALLPAPER_DIR"
		return 1
	fi
	
	# Build rofi menu with image icons
	local menu_items=""
	for i in "${!wallpapers[@]}"; do
		menu_items+="${wallpapers[$i]}\x00icon\x1f${wallpaper_paths[$i]}\n"
	done
	
	# Use rofi with image preview support in grid layout
	local selected=$(echo -ne "$menu_items" | rofi -dmenu -i -p "Select Wallpaper" \
		-theme ${theme} \
		-show-icons \
		-theme-str 'window { width: 90%; height: 85%; }' \
		-theme-str 'mainbox { padding: 0px; }' \
		-theme-str 'listview { columns: 5; lines: 3; fixed-columns: false; spacing: 2px; scrollbar: true; }' \
		-theme-str 'scrollbar { width: 4px; padding: 0px; }' \
		-theme-str 'element { orientation: vertical; padding: 0px; border: 0px; margin: 0px; border-radius: 0px; }' \
		-theme-str 'element normal.normal, element alternate.normal { background-color: transparent; }' \
		-theme-str 'element selected.normal { background-color: rgba(100, 100, 100, 0.3); }' \
		-theme-str 'element-icon { size: 12em; horizontal-align: 0.5; border: 0px; background-color: transparent; padding: 0px; margin: 0px; }' \
		-theme-str 'element-text { enabled: false; }')
	
	if [[ -n "$selected" ]]; then
		local full_path=$(find "$WALLPAPER_DIR" -type f -name "$selected" | head -n1)
		if [[ -n "$full_path" ]]; then
			set_wallpaper "$full_path"
			save_current_wallpaper "$full_path"
		fi
	fi
}

# Set wallpaper based on available tools
set_wallpaper() {
	local wallpaper="$1"
	
	if [[ ! -f "$wallpaper" ]]; then
		notify_user "Wallpaper file not found: $wallpaper"
		return 1
	fi
	
	# Detect window manager/compositor and set wallpaper accordingly
	if command -v awww &> /dev/null && pgrep -x awww-daemon &> /dev/null; then
		# Hyprland/Wayland with swww
		awww img "$wallpaper" --transition-type random --transition-duration 2
		notify_user "Wallpaper set: $(basename "$wallpaper")"
	elif command -v swaybg &> /dev/null && [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
		# Sway/Wayland with swaybg
		killall swaybg 2>/dev/null
		swaybg -i "$wallpaper" -m fill &
		notify_user "Wallpaper set: $(basename "$wallpaper")"
	elif command -v hyprctl &> /dev/null; then
		# Hyprland
		hyprctl hyprpaper preload "$wallpaper" 2>/dev/null
		hyprctl hyprpaper wallpaper ",$wallpaper" 2>/dev/null
		notify_user "Wallpaper set: $(basename "$wallpaper")"
	elif command -v feh &> /dev/null; then
		# X11 with feh
		feh --bg-fill "$wallpaper"
		notify_user "Wallpaper set: $(basename "$wallpaper")"
	elif command -v nitrogen &> /dev/null; then
		# X11 with nitrogen
		nitrogen --set-zoom-fill --save "$wallpaper"
		notify_user "Wallpaper set: $(basename "$wallpaper")"
	elif command -v xwallpaper &> /dev/null; then
		# X11 with xwallpaper
		xwallpaper --zoom "$wallpaper"
		notify_user "Wallpaper set: $(basename "$wallpaper")"
	else
		notify_user "No wallpaper setter found. Install: swww, swaybg, feh, nitrogen, or xwallpaper"
		return 1
	fi
}

# Save current wallpaper path
save_current_wallpaper() {
	echo "$1" > "$CONFIG_DIR/.current_wallpaper"
	
	# Create symlink in hypr_shared for hyprlock and other tools
	local wallpaper_link="$HYPR_SHARED_DIR/current_wallpaper"
	rm -f "$wallpaper_link"
	ln -s "$1" "$wallpaper_link"
	
	# Copy wallpaper to system location for SDDM
	local sddm_wallpaper_dir="/usr/share/wallpapers"
	local sddm_wallpaper="$sddm_wallpaper_dir/current_wallpaper.jpg"
	
	if [[ -d "$sddm_wallpaper_dir" ]]; then
		# Copy to system location (requires sudo)
		if sudo cp "$1" "$sddm_wallpaper" 2>/dev/null; then
			sudo chmod 644 "$sddm_wallpaper" 2>/dev/null
		fi
	fi
	
	# Ensure permissions for hyprlock
	chmod 644 "$1" 2>/dev/null || true
	chmod 755 "$HYPR_SHARED_DIR" 2>/dev/null || true
	chmod 644 "$wallpaper_link" 2>/dev/null || true
}

# Get current wallpaper path
get_current_wallpaper() {
	if [[ -f "$CONFIG_DIR/.current_wallpaper" ]]; then
		cat "$CONFIG_DIR/.current_wallpaper"
	fi
}

# Save favorite wallpaper
save_favorite_wallpaper() {
	echo "$1" > "$CONFIG_DIR/.favorite_wallpaper"
	notify_user "Favorite saved: $(basename "$1")"
}

# Get favorite wallpaper
get_favorite_wallpaper() {
	if [[ -f "$CONFIG_DIR/.favorite_wallpaper" ]]; then
		cat "$CONFIG_DIR/.favorite_wallpaper"
	fi
}

# Set random wallpaper
set_random_wallpaper() {
	local wallpapers=()
	while IFS= read -r wallpaper; do
		wallpapers+=("$wallpaper")
	done < <(get_wallpapers)
	
	if [[ ${#wallpapers[@]} -eq 0 ]]; then
		notify_user "No wallpapers found in $WALLPAPER_DIR"
		return 1
	fi
	
	local random_wallpaper="${wallpapers[$RANDOM % ${#wallpapers[@]}]}"
	set_wallpaper "$random_wallpaper"
	save_current_wallpaper "$random_wallpaper"
}

# Get wallpaper index
get_wallpaper_index() {
	local current="$1"
	local wallpapers=()
	while IFS= read -r wallpaper; do
		wallpapers+=("$wallpaper")
	done < <(get_wallpapers | sort)
	
	for i in "${!wallpapers[@]}"; do
		if [[ "${wallpapers[$i]}" == "$current" ]]; then
			echo "$i"
			return
		fi
	done
	echo "-1"
}

# Set previous wallpaper
set_previous_wallpaper() {
	local current=$(get_current_wallpaper)
	if [[ -z "$current" ]]; then
		notify_user "No current wallpaper set"
		return 1
	fi
	
	local wallpapers=()
	while IFS= read -r wallpaper; do
		wallpapers+=("$wallpaper")
	done < <(get_wallpapers | sort)
	
	if [[ ${#wallpapers[@]} -eq 0 ]]; then
		notify_user "No wallpapers found"
		return 1
	fi
	
	local current_index=$(get_wallpaper_index "$current")
	local prev_index=$(( (current_index - 1 + ${#wallpapers[@]}) % ${#wallpapers[@]} ))
	
	set_wallpaper "${wallpapers[$prev_index]}"
	save_current_wallpaper "${wallpapers[$prev_index]}"
}

# Set next wallpaper
set_next_wallpaper() {
	local current=$(get_current_wallpaper)
	if [[ -z "$current" ]]; then
		notify_user "No current wallpaper set"
		return 1
	fi
	
	local wallpapers=()
	while IFS= read -r wallpaper; do
		wallpapers+=("$wallpaper")
	done < <(get_wallpapers | sort)
	
	if [[ ${#wallpapers[@]} -eq 0 ]]; then
		notify_user "No wallpapers found"
		return 1
	fi
	
	local current_index=$(get_wallpaper_index "$current")
	local next_index=$(( (current_index + 1) % ${#wallpapers[@]} ))
	
	set_wallpaper "${wallpapers[$next_index]}"
	save_current_wallpaper "${wallpapers[$next_index]}"
}

# Set favorite wallpaper
set_favorite_wallpaper() {
	local current=$(get_current_wallpaper)
	if [[ -n "$current" ]] && [[ -f "$current" ]]; then
		# If we have a current wallpaper, ask to save it as favorite or load favorite
		local choice=$(echo -e "Load Favorite\nSave Current as Favorite" | rofi -dmenu -p "Favorite Wallpaper" -theme ${theme})
		
		if [[ "$choice" == "Save Current as Favorite" ]]; then
			save_favorite_wallpaper "$current"
		elif [[ "$choice" == "Load Favorite" ]]; then
			local favorite=$(get_favorite_wallpaper)
			if [[ -n "$favorite" ]] && [[ -f "$favorite" ]]; then
				set_wallpaper "$favorite"
				save_current_wallpaper "$favorite"
			else
				notify_user "No favorite wallpaper saved"
			fi
		fi
	else
		# Just try to load favorite
		local favorite=$(get_favorite_wallpaper)
		if [[ -n "$favorite" ]] && [[ -f "$favorite" ]]; then
			set_wallpaper "$favorite"
			save_current_wallpaper "$favorite"
		else
			notify_user "No favorite wallpaper saved"
		fi
	fi
}

# Open wallpaper directory
open_wallpaper_dir() {
	if command -v thunar &> /dev/null; then
		thunar "$WALLPAPER_DIR" &
	elif command -v nautilus &> /dev/null; then
		nautilus "$WALLPAPER_DIR" &
	elif command -v dolphin &> /dev/null; then
		dolphin "$WALLPAPER_DIR" &
	elif command -v pcmanfm &> /dev/null; then
		pcmanfm "$WALLPAPER_DIR" &
	elif command -v nemo &> /dev/null; then
		nemo "$WALLPAPER_DIR" &
	else
		notify_user "No file manager found"
	fi
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		select_wallpaper
	elif [[ "$1" == '--opt2' ]]; then
		set_random_wallpaper
	elif [[ "$1" == '--opt3' ]]; then
		set_previous_wallpaper
	elif [[ "$1" == '--opt4' ]]; then
		set_next_wallpaper
	elif [[ "$1" == '--opt5' ]]; then
		set_favorite_wallpaper
	elif [[ "$1" == '--opt6' ]]; then
		open_wallpaper_dir
	fi
}

# Check for direct arguments
if [[ "$1" == "--grid" ]] || [[ "$1" == "--select" ]]; then
	# Open wallpaper grid directly
	select_wallpaper
	exit 0
elif [[ "$1" == "--random" ]]; then
	set_random_wallpaper
	exit 0
elif [[ "$1" == "--next" ]]; then
	set_next_wallpaper
	exit 0
elif [[ "$1" == "--prev" ]] || [[ "$1" == "--previous" ]]; then
	set_previous_wallpaper
	exit 0
elif [[ "$1" == "--favorite" ]]; then
	set_favorite_wallpaper
	exit 0
fi

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
    $option_5)
		run_cmd --opt5
        ;;
    $option_6)
		run_cmd --opt6
        ;;
esac

