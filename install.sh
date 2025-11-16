#!/bin/bash

# Don't exit on error for individual stow operations
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where the script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command line arguments
INSTALL_AUR=false
UPDATE_PKGLIST=false

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -a, --aur          Also install AUR packages from pkglist_aur.txt"
  echo "  -u, --update-list  Update pkglist.txt and pkglist_aur.txt before installing"
  echo "  -h, --help         Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                 Install pacman packages and stow dotfiles"
  echo "  $0 -a              Also install AUR packages"
  echo "  $0 -u              Update package lists, then install"
  echo "  $0 -a -u           Update lists and install both pacman and AUR packages"
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -a | --aur)
    INSTALL_AUR=true
    shift
    ;;
  -u | --update-list)
    UPDATE_PKGLIST=true
    shift
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    echo -e "${RED}Unknown option: $1${NC}"
    show_help
    exit 1
    ;;
  esac
done

# Update package lists if requested
if [ "$UPDATE_PKGLIST" = true ]; then
  echo -e "${BLUE}Updating package lists...${NC}"
  if [ -f "$DOTFILES_DIR/update-pkglist.sh" ]; then
    bash "$DOTFILES_DIR/update-pkglist.sh"
  else
    echo -e "${RED}Error: update-pkglist.sh not found${NC}"
    exit 1
  fi
  echo ""
fi

echo -e "${GREEN}Starting dotfiles installation...${NC}"

# Check if running as root for package installation
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}Please do not run this script as root${NC}"
  exit 1
fi

# Check if stow is installed
if ! command -v stow &>/dev/null; then
  echo -e "${YELLOW}stow is not installed. Installing stow...${NC}"
  sudo pacman -S --noconfirm stow
fi

# Install pacman packages
if [ -f "$DOTFILES_DIR/pkglist.txt" ]; then
  echo -e "${GREEN}Installing pacman packages from pkglist.txt...${NC}"
  # Filter out empty lines and comments, then install
  PACKAGES=$(cat "$DOTFILES_DIR/pkglist.txt" | grep -v '^#' | grep -v '^$' | tr '\n' ' ')
  if [ -n "$PACKAGES" ]; then
    sudo pacman -S --needed --noconfirm $PACKAGES
    echo -e "${GREEN}Pacman packages installed successfully!${NC}"
  else
    echo -e "${YELLOW}Warning: No packages found in pkglist.txt${NC}"
  fi
else
  echo -e "${YELLOW}Warning: pkglist.txt not found. Skipping package installation.${NC}"
fi

# Install AUR packages if requested
if [ "$INSTALL_AUR" = true ]; then
  if [ -f "$DOTFILES_DIR/pkglist_aur.txt" ]; then
    echo -e "${GREEN}Installing AUR packages from pkglist_aur.txt...${NC}"

    # Check for AUR helper
    if command -v yay &>/dev/null; then
      AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
      AUR_HELPER="paru"
    else
      echo -e "${RED}Error: No AUR helper found (yay or paru). Please install one first.${NC}"
      echo -e "${YELLOW}You can install yay with: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si${NC}"
      exit 1
    fi

    # Filter out empty lines and comments, then install
    AUR_PACKAGES=$(cat "$DOTFILES_DIR/pkglist_aur.txt" | grep -v '^#' | grep -v '^$' | tr '\n' ' ')
    if [ -n "$AUR_PACKAGES" ]; then
      $AUR_HELPER -S --needed --noconfirm $AUR_PACKAGES
      echo -e "${GREEN}AUR packages installed successfully!${NC}"
    else
      echo -e "${YELLOW}Warning: No packages found in pkglist_aur.txt${NC}"
    fi
  else
    echo -e "${YELLOW}Warning: pkglist_aur.txt not found. Skipping AUR package installation.${NC}"
  fi
fi

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# List of directories to stow (excluding non-config directories)
STOW_DIRS=(
  "antibody"
  "ghostty"
  "hypr"
  "kitty"
  "lazygit"
  "nvim"
  "rofi"
  "starship"
  "swaync"
  "tmux"
  "uwsm"
  "wallust"
  "waybar"
  "wlogout"
  "zellij"
  "zsh"
)

# Use stow to create symlinks
echo -e "${GREEN}Creating symlinks with stow...${NC}"
for dir in "${STOW_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "${YELLOW}Stowing $dir...${NC}"
    stow -t ~ "$dir" || echo -e "${RED}Warning: Failed to stow $dir${NC}"
  else
    echo -e "${YELLOW}Warning: Directory $dir not found, skipping...${NC}"
  fi
done

# Post-installation tasks
echo -e "${GREEN}Running post-installation tasks...${NC}"

# Generate antibody plugins if .zsh_plugins.txt exists
if [ -f ~/.zsh_plugins.txt ]; then
  echo -e "${YELLOW}Generating antibody plugins...${NC}"
  antibody bundle <~/.zsh_plugins.txt >~/.zsh_plugins.sh
fi

# Create waybar style symlink if needed
# Note: Adjust the source path based on your actual waybar style file location
if [ -d ~/.config/waybar/style ]; then
  # Try to find and link the Half-Moon.css file
  HALF_MOON_CSS=$(find ~/.config/waybar/style -name "*Half-Moon.css" -o -name "*Half-Moon*.css" 2>/dev/null | head -1)
  if [ -n "$HALF_MOON_CSS" ] && [ ! -f ~/.config/waybar/style.css ]; then
    echo -e "${YELLOW}Creating waybar style symlink...${NC}"
    ln -sf "$HALF_MOON_CSS" ~/.config/waybar/style.css
  fi
fi

# Create swaync style symlink if needed
if [ -f ~/.config/swaync/colors-wallust.css ]; then
  echo -e "${YELLOW}Creating swaync style symlink...${NC}"
  ln -sf ~/.config/swaync/colors-wallust.css ~/.config/swaync/style.css || true
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Note: You may need to log out and log back in for some changes to take effect.${NC}"

c# Usage Examples:
#
#      1 │# Basic installation (pacman packages + stow)
#      2 │./install.sh
#      3 │
#      4 │# Also install AUR packages
#      5 │./install.sh -a
#      6 │
#      7 │# Update package lists first, then install
#      8 │./install.sh -u
#      9 │
#     10 │# Update lists and install everything (pacman + AUR)
#     11 │./install.sh -a -u
