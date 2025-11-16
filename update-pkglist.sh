#!/bin/bash

# Script to automatically update pkglist.txt and pkglist_aur.txt
# from currently installed packages
#
# Usage:
#   ./update-pkglist.sh
#
# This script will:
#   1. Generate pkglist.txt from explicitly installed pacman packages
#   2. Generate pkglist_aur.txt from AUR packages (detected via yay/paru or pacman)
#   3. Create backups of existing files (.bak)
#   4. Sort packages alphabetically
#
# The generated lists can then be used with install.sh to restore packages
# on a fresh system.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where the script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKGLIST_FILE="$DOTFILES_DIR/pkglist.txt"
PKGLIST_AUR_FILE="$DOTFILES_DIR/pkglist_aur.txt"

# Packages to exclude from the list (base system packages that are always needed)
EXCLUDE_PACKAGES=(
    "base"
    "base-devel"
    "linux"
    "linux-firmware"
    "linux-headers"
)

# Function to check if a package should be excluded
should_exclude() {
    local pkg=$1
    for exclude in "${EXCLUDE_PACKAGES[@]}"; do
        if [ "$pkg" = "$exclude" ]; then
            return 0
        fi
    done
    return 1
}

echo -e "${BLUE}Updating package lists...${NC}"

# Check if pacman is available
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}Error: pacman is not available. This script is for Arch Linux systems.${NC}"
    exit 1
fi

# Backup existing files
if [ -f "$PKGLIST_FILE" ]; then
    echo -e "${YELLOW}Backing up existing pkglist.txt...${NC}"
    cp "$PKGLIST_FILE" "${PKGLIST_FILE}.bak"
fi

if [ -f "$PKGLIST_AUR_FILE" ]; then
    echo -e "${YELLOW}Backing up existing pkglist_aur.txt...${NC}"
    cp "$PKGLIST_AUR_FILE" "${PKGLIST_AUR_FILE}.bak"
fi

# Generate pacman package list (native packages only, excluding AUR)
echo -e "${GREEN}Generating pkglist.txt (pacman packages)...${NC}"
> "$PKGLIST_FILE"  # Clear the file

# Get explicitly installed native packages, sort them, and filter
pacman -Qqen | sort | while read -r pkg; do
    if ! should_exclude "$pkg"; then
        echo "$pkg" >> "$PKGLIST_FILE"
    fi
done

# Add excluded packages back if they're installed (for completeness)
for exclude in "${EXCLUDE_PACKAGES[@]}"; do
    if pacman -Qqen | grep -q "^${exclude}$"; then
        echo "$exclude" >> "$PKGLIST_FILE"
    fi
done

# Sort the final file
sort -o "$PKGLIST_FILE" "$PKGLIST_FILE"

PACMAN_COUNT=$(wc -l < "$PKGLIST_FILE" | tr -d ' ')
echo -e "${GREEN}Found $PACMAN_COUNT pacman packages${NC}"

# Generate AUR package list
echo -e "${GREEN}Generating pkglist_aur.txt (AUR packages)...${NC}"
> "$PKGLIST_AUR_FILE"  # Clear the file

# Check for AUR helpers
if command -v yay &> /dev/null; then
    echo -e "${YELLOW}Using yay to detect AUR packages...${NC}"
    pacman -Qqem | sort > "$PKGLIST_AUR_FILE"
elif command -v paru &> /dev/null; then
    echo -e "${YELLOW}Using paru to detect AUR packages...${NC}"
    pacman -Qqem | sort > "$PKGLIST_AUR_FILE"
else
    # Fallback: try to detect AUR packages by checking if they're in official repos
    echo -e "${YELLOW}Detecting AUR packages (no yay/paru found)...${NC}"
    pacman -Qqm | sort | while read -r pkg; do
        # Check if package exists in official repos
        if ! pacman -Si "$pkg" &>/dev/null; then
            echo "$pkg" >> "$PKGLIST_AUR_FILE"
        fi
    done
fi

AUR_COUNT=$(wc -l < "$PKGLIST_AUR_FILE" | tr -d ' ')
echo -e "${GREEN}Found $AUR_COUNT AUR packages${NC}"

# Show summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Package lists updated successfully!${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Pacman packages: ${GREEN}$PACMAN_COUNT${NC} → $PKGLIST_FILE"
echo -e "AUR packages:    ${GREEN}$AUR_COUNT${NC} → $PKGLIST_AUR_FILE"
echo ""
echo -e "${YELLOW}Backups saved as:${NC}"
echo -e "  - ${PKGLIST_FILE}.bak"
echo -e "  - ${PKGLIST_AUR_FILE}.bak"
echo ""
echo -e "${YELLOW}Tip: Review the lists and remove any packages you don't want to install on a fresh system.${NC}"
