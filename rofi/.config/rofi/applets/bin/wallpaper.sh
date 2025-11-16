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
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
  list_col='6'
  list_row='1'
  win_width='670px'
fi

# Options
layout=$(cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2)
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

# Get list of wallpapers with optional filtering
get_wallpapers() {
  local filter_ext="${1:-}"  # Filter by extension (e.g., "jpg", "png")
  local filter_name="${2:-}"  # Filter by name pattern
  local filter_size_min="${3:-}"  # Minimum size in bytes
  local filter_size_max="${4:-}"  # Maximum size in bytes
  
  local find_cmd="find \"$WALLPAPER_DIR\" -type f"
  
  # Build extension filter
  if [[ -n "$filter_ext" ]]; then
    # Convert comma-separated extensions to find conditions
    IFS=',' read -ra exts <<< "$filter_ext"
    local ext_conditions=""
    for ext in "${exts[@]}"; do
      ext=$(echo "$ext" | tr -d ' ')
      if [[ -n "$ext_conditions" ]]; then
        ext_conditions+=" -o"
      fi
      ext_conditions+=" -iname \"*.$ext\""
    done
    find_cmd+=" \\( $ext_conditions \\)"
  else
    # Default: all supported image formats
    find_cmd+=" \\( -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.png\" -o -iname \"*.bmp\" -o -iname \"*.gif\" -o -iname \"*.webp\" \\)"
  fi
  
  # Apply name filter
  if [[ -n "$filter_name" ]]; then
    find_cmd+=" -iname \"*${filter_name}*\""
  fi
  
  # Execute find and filter by size if needed
  if [[ -n "$filter_size_min" ]] || [[ -n "$filter_size_max" ]]; then
    while IFS= read -r file; do
      [[ ! -f "$file" ]] && continue
      local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
      if [[ -n "$filter_size_min" ]] && [[ $size -lt $filter_size_min ]]; then
        continue
      fi
      if [[ -n "$filter_size_max" ]] && [[ $size -gt $filter_size_max ]]; then
        continue
      fi
      echo "$file"
    done < <(eval "$find_cmd 2>/dev/null")
  else
    eval "$find_cmd 2>/dev/null"
  fi
}

# Sort wallpapers
sort_wallpapers() {
  local sort_method="${1:-name_asc}"  # name_asc, name_desc, date_new, date_old, size_large, size_small, random
  local wallpapers=("${@:2}")
  
  if [[ ${#wallpapers[@]} -eq 0 ]]; then
    return
  fi
  
  # Create temporary file to store sorted results
  local tmp_file=$(mktemp)
  
  case "$sort_method" in
    name_asc)
      printf '%s\n' "${wallpapers[@]}" | sort
      ;;
    name_desc)
      printf '%s\n' "${wallpapers[@]}" | sort -r
      ;;
    date_new)
      # Sort by modification time, newest first
      for wp in "${wallpapers[@]}"; do
        local mtime=$(stat -f%m "$wp" 2>/dev/null || stat -c%Y "$wp" 2>/dev/null || echo "0")
        echo -e "$mtime\t$wp"
      done | sort -rn | cut -f2-
      ;;
    date_old)
      # Sort by modification time, oldest first
      for wp in "${wallpapers[@]}"; do
        local mtime=$(stat -f%m "$wp" 2>/dev/null || stat -c%Y "$wp" 2>/dev/null || echo "0")
        echo -e "$mtime\t$wp"
      done | sort -n | cut -f2-
      ;;
    size_large)
      # Sort by file size, largest first
      for wp in "${wallpapers[@]}"; do
        local size=$(stat -f%z "$wp" 2>/dev/null || stat -c%s "$wp" 2>/dev/null || echo "0")
        echo -e "$size\t$wp"
      done | sort -rn | cut -f2-
      ;;
    size_small)
      # Sort by file size, smallest first
      for wp in "${wallpapers[@]}"; do
        local size=$(stat -f%z "$wp" 2>/dev/null || stat -c%s "$wp" 2>/dev/null || echo "0")
        echo -e "$size\t$wp"
      done | sort -n | cut -f2-
      ;;
    random)
      # Randomize order
      if command -v shuf &>/dev/null; then
        printf '%s\n' "${wallpapers[@]}" | shuf
      else
        # Fallback: use awk for randomization if shuf is not available
        printf '%s\n' "${wallpapers[@]}" | awk 'BEGIN{srand()}{print rand()"\t"$0}' | sort -n | cut -f2-
      fi
      ;;
    *)
      # Default: name ascending
      printf '%s\n' "${wallpapers[@]}" | sort
      ;;
  esac
  
  rm -f "$tmp_file"
}

# Save sort preference
save_sort_preference() {
  echo "$1" >"$CONFIG_DIR/.wallpaper_sort"
}

# Get sort preference
get_sort_preference() {
  if [[ -f "$CONFIG_DIR/.wallpaper_sort" ]]; then
    cat "$CONFIG_DIR/.wallpaper_sort"
  else
    echo "name_asc"  # Default
  fi
}

# Save filter preferences
save_filter_preferences() {
  local filter_ext="$1"
  local filter_name="$2"
  local filter_size_min="$3"
  local filter_size_max="$4"
  
  echo "EXT:$filter_ext" >"$CONFIG_DIR/.wallpaper_filters"
  echo "NAME:$filter_name" >>"$CONFIG_DIR/.wallpaper_filters"
  echo "SIZE_MIN:$filter_size_min" >>"$CONFIG_DIR/.wallpaper_filters"
  echo "SIZE_MAX:$filter_size_max" >>"$CONFIG_DIR/.wallpaper_filters"
}

# Get filter preferences
get_filter_preferences() {
  local filter_ext=""
  local filter_name=""
  local filter_size_min=""
  local filter_size_max=""
  
  if [[ -f "$CONFIG_DIR/.wallpaper_filters" ]]; then
    while IFS= read -r line; do
      if [[ "$line" =~ ^EXT:(.*)$ ]]; then
        filter_ext="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^NAME:(.*)$ ]]; then
        filter_name="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^SIZE_MIN:(.*)$ ]]; then
        filter_size_min="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^SIZE_MAX:(.*)$ ]]; then
        filter_size_max="${BASH_REMATCH[1]}"
      fi
    done <"$CONFIG_DIR/.wallpaper_filters"
  fi
  
  echo "$filter_ext|$filter_name|$filter_size_min|$filter_size_max"
}

# Show sort menu
show_sort_menu() {
  local current_sort=$(get_sort_preference)
  local sort_options=(
    "Name (A-Z)"
    "Name (Z-A)"
    "Date (Newest)"
    "Date (Oldest)"
    "Size (Largest)"
    "Size (Smallest)"
    "Random"
  )
  
  local selected=$(printf '%s\n' "${sort_options[@]}" | rofi -dmenu -i -p "Sort By" \
    -theme ${theme} \
    -selected-row "$(get_sort_index "$current_sort")")
  
  case "$selected" in
    "Name (A-Z)")
      save_sort_preference "name_asc"
      ;;
    "Name (Z-A)")
      save_sort_preference "name_desc"
      ;;
    "Date (Newest)")
      save_sort_preference "date_new"
      ;;
    "Date (Oldest)")
      save_sort_preference "date_old"
      ;;
    "Size (Largest)")
      save_sort_preference "size_large"
      ;;
    "Size (Smallest)")
      save_sort_preference "size_small"
      ;;
    "Random")
      save_sort_preference "random"
      ;;
  esac
}

# Get sort index for menu selection
get_sort_index() {
  local sort="$1"
  case "$sort" in
    name_asc) echo "0" ;;
    name_desc) echo "1" ;;
    date_new) echo "2" ;;
    date_old) echo "3" ;;
    size_large) echo "4" ;;
    size_small) echo "5" ;;
    random) echo "6" ;;
    *) echo "0" ;;
  esac
}

# Show filter menu
show_filter_menu() {
  local filters=$(get_filter_preferences)
  IFS='|' read -r filter_ext filter_name filter_size_min filter_size_max <<< "$filters"
  
  local filter_options=(
    "Filter by Extension"
    "Filter by Name"
    "Filter by Size"
    "Clear All Filters"
  )
  
  local selected=$(printf '%s\n' "${filter_options[@]}" | rofi -dmenu -i -p "Filter Options" \
    -theme ${theme})
  
  case "$selected" in
    "Filter by Extension")
      filter_by_extension "$filter_ext"
      ;;
    "Filter by Name")
      filter_by_name "$filter_name"
      ;;
    "Filter by Size")
      filter_by_size "$filter_size_min" "$filter_size_max"
      ;;
    "Clear All Filters")
      save_filter_preferences "" "" "" ""
      notify_user "All filters cleared"
      ;;
  esac
}

# Filter by extension
filter_by_extension() {
  local current_ext="$1"
  local ext_options=(
    "All Formats"
    "JPG/JPEG"
    "PNG"
    "WebP"
    "GIF"
    "BMP"
    "Custom..."
  )
  
  local selected=$(printf '%s\n' "${ext_options[@]}" | rofi -dmenu -i -p "Filter by Extension" \
    -theme ${theme})
  
  local new_ext=""
  case "$selected" in
    "All Formats")
      new_ext=""
      ;;
    "JPG/JPEG")
      new_ext="jpg,jpeg"
      ;;
    "PNG")
      new_ext="png"
      ;;
    "WebP")
      new_ext="webp"
      ;;
    "GIF")
      new_ext="gif"
      ;;
    "BMP")
      new_ext="bmp"
      ;;
    "Custom...")
      new_ext=$(rofi -dmenu -p "Enter extensions (comma-separated):" -theme ${theme})
      ;;
  esac
  
  if [[ -n "$new_ext" ]] || [[ "$selected" == "All Formats" ]]; then
    local filters=$(get_filter_preferences)
    IFS='|' read -r _ filter_name filter_size_min filter_size_max <<< "$filters"
    save_filter_preferences "$new_ext" "$filter_name" "$filter_size_min" "$filter_size_max"
    notify_user "Extension filter: ${new_ext:-All}"
  fi
}

# Filter by name
filter_by_name() {
  local current_name="$1"
  local prompt_text="Enter name pattern (leave empty to clear):"
  if [[ -n "$current_name" ]]; then
    prompt_text="Current: $current_name - Enter new pattern (leave empty to clear):"
  fi
  
  local new_name=$(rofi -dmenu -p "$prompt_text" -theme ${theme} -filter "$current_name")
  
  local filters=$(get_filter_preferences)
  IFS='|' read -r filter_ext _ filter_size_min filter_size_max <<< "$filters"
  save_filter_preferences "$filter_ext" "$new_name" "$filter_size_min" "$filter_size_max"
  
  if [[ -n "$new_name" ]]; then
    notify_user "Name filter: $new_name"
  else
    notify_user "Name filter cleared"
  fi
}

# Filter by size
filter_by_size() {
  local current_min="$1"
  local current_max="$2"
  
  local size_options=(
    "Small (< 1MB)"
    "Medium (1MB - 5MB)"
    "Large (5MB - 20MB)"
    "Very Large (> 20MB)"
    "Custom Range..."
    "Clear Size Filter"
  )
  
  local selected=$(printf '%s\n' "${size_options[@]}" | rofi -dmenu -i -p "Filter by Size" \
    -theme ${theme})
  
  local new_min=""
  local new_max=""
  
  case "$selected" in
    "Small (< 1MB)")
      new_max="1048576"  # 1MB in bytes
      ;;
    "Medium (1MB - 5MB)")
      new_min="1048576"   # 1MB
      new_max="5242880"   # 5MB
      ;;
    "Large (5MB - 20MB)")
      new_min="5242880"   # 5MB
      new_max="20971520"  # 20MB
      ;;
    "Very Large (> 20MB)")
      new_min="20971520"  # 20MB
      ;;
    "Custom Range...")
      local min_input=$(rofi -dmenu -p "Min size in MB (leave empty for no min):" -theme ${theme})
      local max_input=$(rofi -dmenu -p "Max size in MB (leave empty for no max):" -theme ${theme})
      if [[ -n "$min_input" ]] && [[ "$min_input" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        if command -v bc &>/dev/null; then
          new_min=$(echo "$min_input * 1048576" | bc | cut -d. -f1)
        else
          # Fallback: use awk for calculation
          new_min=$(awk "BEGIN {printf \"%.0f\", $min_input * 1048576}")
        fi
      fi
      if [[ -n "$max_input" ]] && [[ "$max_input" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        if command -v bc &>/dev/null; then
          new_max=$(echo "$max_input * 1048576" | bc | cut -d. -f1)
        else
          # Fallback: use awk for calculation
          new_max=$(awk "BEGIN {printf \"%.0f\", $max_input * 1048576}")
        fi
      fi
      ;;
    "Clear Size Filter")
      new_min=""
      new_max=""
      ;;
  esac
  
  local filters=$(get_filter_preferences)
  IFS='|' read -r filter_ext filter_name _ _ <<< "$filters"
  save_filter_preferences "$filter_ext" "$filter_name" "$new_min" "$new_max"
  
  if [[ -n "$new_min" ]] || [[ -n "$new_max" ]]; then
    local min_mb="0MB"
    local max_mb="∞"
    if [[ -n "$new_min" ]]; then
      if command -v bc &>/dev/null; then
        min_mb="$(echo "scale=2; $new_min / 1048576" | bc)MB"
      else
        min_mb="$(awk "BEGIN {printf \"%.2f\", $new_min / 1048576}")MB"
      fi
    fi
    if [[ -n "$new_max" ]]; then
      if command -v bc &>/dev/null; then
        max_mb="$(echo "scale=2; $new_max / 1048576" | bc)MB"
      else
        max_mb="$(awk "BEGIN {printf \"%.2f\", $new_max / 1048576}")MB"
      fi
    fi
    notify_user "Size filter: $min_mb - $max_mb"
  else
    notify_user "Size filter cleared"
  fi
}

# Select wallpaper using rofi with image previews
select_wallpaper() {
  # Get current filter preferences
  local filters=$(get_filter_preferences)
  IFS='|' read -r filter_ext filter_name filter_size_min filter_size_max <<< "$filters"
  
  # Get filtered wallpapers
  local all_wallpapers=()
  while IFS= read -r wallpaper; do
    all_wallpapers+=("$wallpaper")
  done < <(get_wallpapers "$filter_ext" "$filter_name" "$filter_size_min" "$filter_size_max")
  
  if [[ ${#all_wallpapers[@]} -eq 0 ]]; then
    notify_user "No wallpapers found matching filters in $WALLPAPER_DIR"
    return 1
  fi
  
  # Get sort preference and sort wallpapers
  local sort_method=$(get_sort_preference)
  local sorted_wallpapers=()
  while IFS= read -r wallpaper; do
    sorted_wallpapers+=("$wallpaper")
  done < <(sort_wallpapers "$sort_method" "${all_wallpapers[@]}")
  
  # Build arrays for display
  local wallpapers=()
  local wallpaper_paths=()
  for wallpaper in "${sorted_wallpapers[@]}"; do
    wallpaper_paths+=("$wallpaper")
    wallpapers+=("$(basename "$wallpaper")")
  done
  
  # Build status message with keyboard shortcuts shown as small text buttons
  local sort_display=$(get_sort_display_name "$sort_method")
  local filter_indicator=""
  if [[ -n "$filter_ext" ]] || [[ -n "$filter_name" ]] || [[ -n "$filter_size_min" ]] || [[ -n "$filter_size_max" ]]; then
    filter_indicator=" (filtered)"
  fi
  local status_msg="[Sort: $sort_display]  [Filter]  |  Found ${#wallpapers[@]} wallpapers$filter_indicator  |  Alt+1: Sort  Alt+2: Filter"

  # Build rofi menu - only wallpapers, no status bar items
  local menu_items=""
  for i in "${!wallpapers[@]}"; do
    menu_items+="${wallpapers[$i]}\x00icon\x1f${wallpaper_paths[$i]}\n"
  done

  # Use rofi with image preview support in grid layout
  # Status bar buttons shown in mesg, accessed via keyboard shortcuts only
  local selected=$(echo -ne "$menu_items" | rofi -dmenu -i -p "Select Wallpaper" \
    -theme ${theme} \
    -show-icons \
    -mesg "$status_msg" \
    -kb-custom-1 "Alt+1" \
    -kb-custom-2 "Alt+2" \
    -theme-str 'window { width: 90%; height: 85%; }' \
    -theme-str 'mainbox { padding: 0px; }' \
    -theme-str 'listview { columns: 5; lines: 3; fixed-columns: false; spacing: 2px; scrollbar: true; }' \
    -theme-str 'scrollbar { width: 4px; padding: 0px; }' \
    -theme-str 'element { orientation: vertical; padding: 0px; border: 0px; margin: 0px; border-radius: 0px; }' \
    -theme-str 'element normal.normal, element alternate.normal { background-color: transparent; }' \
    -theme-str 'element selected.normal { background-color: rgba(100, 100, 100, 0.3); }' \
    -theme-str 'element-icon { size: 12em; horizontal-align: 0.5; border: 0px; background-color: transparent; padding: 0px; margin: 0px; }' \
    -theme-str 'element-text { enabled: false; }')
  
  local exit_code=$?
  
  # Handle keyboard shortcuts (Alt+1 for Sort, Alt+2 for Filter)
  if [[ $exit_code -eq 10 ]]; then
    # Alt+1 pressed - show sort menu
    show_sort_menu
    select_wallpaper
    return
  elif [[ $exit_code -eq 11 ]]; then
    # Alt+2 pressed - show filter menu
    show_filter_menu
    select_wallpaper
    return
  fi
  
  # Handle wallpaper selection
  if [[ -z "$selected" ]]; then
    return
  fi
  
  # A wallpaper was selected - rofi returns just the filename
  local wallpaper_name=$(echo "$selected" | xargs)  # trim whitespace
  
  # Find the wallpaper file
  local full_path=""
  for wp_path in "${wallpaper_paths[@]}"; do
    if [[ "$(basename "$wp_path")" == "$wallpaper_name" ]]; then
      full_path="$wp_path"
      break
    fi
  done
  
  if [[ -n "$full_path" ]] && [[ -f "$full_path" ]]; then
    set_wallpaper "$full_path"
    save_current_wallpaper "$full_path"
  fi
}

# Get display name for sort method
get_sort_display_name() {
  local sort="$1"
  case "$sort" in
    name_asc) echo "Name (A-Z)" ;;
    name_desc) echo "Name (Z-A)" ;;
    date_new) echo "Date (Newest)" ;;
    date_old) echo "Date (Oldest)" ;;
    size_large) echo "Size (Largest)" ;;
    size_small) echo "Size (Smallest)" ;;
    random) echo "Random" ;;
    *) echo "Name (A-Z)" ;;
  esac
}

# Set wallpaper based on available tools
set_wallpaper() {
  local wallpaper="$1"

  if [[ ! -f "$wallpaper" ]]; then
    notify_user "Wallpaper file not found: $wallpaper"
    return 1
  fi

  # Detect window manager/compositor and set wallpaper accordingly
  if command -v awww &>/dev/null && pgrep -x awww-daemon &>/dev/null; then
    # Hyprland/Wayland with swww
    awww img "$wallpaper" --transition-type random --transition-duration 2
    notify_user "Wallpaper set: $(basename "$wallpaper")"
  elif command -v swaybg &>/dev/null && [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    # Sway/Wayland with swaybg
    killall swaybg 2>/dev/null
    swaybg -i "$wallpaper" -m fill &
    notify_user "Wallpaper set: $(basename "$wallpaper")"
  elif command -v hyprctl &>/dev/null; then
    # Hyprland
    hyprctl hyprpaper preload "$wallpaper" 2>/dev/null
    hyprctl hyprpaper wallpaper ",$wallpaper" 2>/dev/null
    notify_user "Wallpaper set: $(basename "$wallpaper")"
  elif command -v feh &>/dev/null; then
    # X11 with feh
    feh --bg-fill "$wallpaper"
    notify_user "Wallpaper set: $(basename "$wallpaper")"
  elif command -v nitrogen &>/dev/null; then
    # X11 with nitrogen
    nitrogen --set-zoom-fill --save "$wallpaper"
    notify_user "Wallpaper set: $(basename "$wallpaper")"
  elif command -v xwallpaper &>/dev/null; then
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
  echo "$1" >"$CONFIG_DIR/.current_wallpaper"

  # Create symlink in hypr_shared for hyprlock and other tools
  local wallpaper_link="$HYPR_SHARED_DIR/current_wallpaper"
  rm -f "$wallpaper_link"
  ln -s "$1" "$wallpaper_link"

  #run wallust
  wallust run --skip-sequences ~/.config/hypr/hypr_shared/current_wallpaper
  killall swaync
  swaync &

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
  echo "$1" >"$CONFIG_DIR/.favorite_wallpaper"
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
  # Get current filter preferences
  local filters=$(get_filter_preferences)
  IFS='|' read -r filter_ext filter_name filter_size_min filter_size_max <<< "$filters"
  
  local wallpapers=()
  while IFS= read -r wallpaper; do
    wallpapers+=("$wallpaper")
  done < <(get_wallpapers "$filter_ext" "$filter_name" "$filter_size_min" "$filter_size_max")

  if [[ ${#wallpapers[@]} -eq 0 ]]; then
    notify_user "No wallpapers found matching filters in $WALLPAPER_DIR"
    return 1
  fi

  local random_wallpaper="${wallpapers[$RANDOM % ${#wallpapers[@]}]}"
  set_wallpaper "$random_wallpaper"
  save_current_wallpaper "$random_wallpaper"
}

# Get wallpaper index
get_wallpaper_index() {
  local current="$1"
  
  # Get current filter preferences
  local filters=$(get_filter_preferences)
  IFS='|' read -r filter_ext filter_name filter_size_min filter_size_max <<< "$filters"
  
  # Get filtered wallpapers
  local all_wallpapers=()
  while IFS= read -r wallpaper; do
    all_wallpapers+=("$wallpaper")
  done < <(get_wallpapers "$filter_ext" "$filter_name" "$filter_size_min" "$filter_size_max")
  
  # Get sort preference and sort wallpapers
  local sort_method=$(get_sort_preference)
  local wallpapers=()
  while IFS= read -r wallpaper; do
    wallpapers+=("$wallpaper")
  done < <(sort_wallpapers "$sort_method" "${all_wallpapers[@]}")

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

  # Get current filter preferences
  local filters=$(get_filter_preferences)
  IFS='|' read -r filter_ext filter_name filter_size_min filter_size_max <<< "$filters"
  
  # Get filtered wallpapers
  local all_wallpapers=()
  while IFS= read -r wallpaper; do
    all_wallpapers+=("$wallpaper")
  done < <(get_wallpapers "$filter_ext" "$filter_name" "$filter_size_min" "$filter_size_max")

  if [[ ${#all_wallpapers[@]} -eq 0 ]]; then
    notify_user "No wallpapers found matching filters"
    return 1
  fi
  
  # Get sort preference and sort wallpapers
  local sort_method=$(get_sort_preference)
  local wallpapers=()
  while IFS= read -r wallpaper; do
    wallpapers+=("$wallpaper")
  done < <(sort_wallpapers "$sort_method" "${all_wallpapers[@]}")

  local current_index=$(get_wallpaper_index "$current")
  if [[ $current_index -eq -1 ]]; then
    # Current wallpaper not in filtered list, use first wallpaper
    current_index=0
  fi
  local prev_index=$(((current_index - 1 + ${#wallpapers[@]}) % ${#wallpapers[@]}))

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

  # Get current filter preferences
  local filters=$(get_filter_preferences)
  IFS='|' read -r filter_ext filter_name filter_size_min filter_size_max <<< "$filters"
  
  # Get filtered wallpapers
  local all_wallpapers=()
  while IFS= read -r wallpaper; do
    all_wallpapers+=("$wallpaper")
  done < <(get_wallpapers "$filter_ext" "$filter_name" "$filter_size_min" "$filter_size_max")

  if [[ ${#all_wallpapers[@]} -eq 0 ]]; then
    notify_user "No wallpapers found matching filters"
    return 1
  fi
  
  # Get sort preference and sort wallpapers
  local sort_method=$(get_sort_preference)
  local wallpapers=()
  while IFS= read -r wallpaper; do
    wallpapers+=("$wallpaper")
  done < <(sort_wallpapers "$sort_method" "${all_wallpapers[@]}")

  local current_index=$(get_wallpaper_index "$current")
  if [[ $current_index -eq -1 ]]; then
    # Current wallpaper not in filtered list, use first wallpaper
    current_index=0
  fi
  local next_index=$(((current_index + 1) % ${#wallpapers[@]}))

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
  if command -v thunar &>/dev/null; then
    thunar "$WALLPAPER_DIR" &
  elif command -v nautilus &>/dev/null; then
    nautilus "$WALLPAPER_DIR" &
  elif command -v dolphin &>/dev/null; then
    dolphin "$WALLPAPER_DIR" &
  elif command -v pcmanfm &>/dev/null; then
    pcmanfm "$WALLPAPER_DIR" &
  elif command -v nemo &>/dev/null; then
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
