#!/bin/bash

# ========================================================================================
# Hyprland Dotfiles Installation Script by Shubham
# A script to automate the setup of a complete, beautiful, and functional desktop.
# ========================================================================================

# --- Stop on any error ---
set -e

# --- Color Definitions for Logging ---
BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
NC="\033[0m" # No Color

# --- Logging Functions ---
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# --- Helper Functions ---
press_enter_to_continue() {
  echo -e "${MAGENTA}Press ENTER to continue...${NC}"
  read -r
}

# ========================================================================================
#                                     MAIN SCRIPT
# ========================================================================================

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done &> /dev/null &


# --- 1. GATHER USER INFORMATION ---
info "First, I need to ask a few questions to set up your system correctly."
read -p "Please enter your desired username: " USERNAME
read -p "Please enter your computer's name (hostname): " HOSTNAME
read -p "Do you want to install and configure GRUB? (y/n): " CONFIGURE_GRUB

press_enter_to_continue

# --- 2. VERIFY PACKAGE LISTS ---
info "Verifying that package lists exist..."
if [ ! -f "./fresh/pkglist.txt" ] || [ ! -f "./fresh/pkglist_aur.txt" ]; then
  error "Package lists (pkglist.txt or pkglist_aur.txt) not found! Please create them first."
fi
success "Package lists found."
press_enter_to_continue

# --- 3. INSTALL PACKAGES ---
info "Installing packages from official repositories..."
sudo pacman -Syu --needed --noconfirm - <./fresh/pkglist.txt

info "Checking for AUR helper (yay)..."
if ! command -v yay &>/dev/null; then
  warn "'yay' not found. Attempting to install it."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi

info "Installing packages from the AUR..."
yay -S --needed --noconfirm - <./fresh/pkglist_aur.txt
success "All packages installed."
press_enter_to_continue

# --- 4. ENABLE SYSTEM SERVICES ---
info "Enabling essential systemd services..."
sudo systemctl enable sddm.service
sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service
# Add any other system-level services here
success "Services enabled."

info "Enabling essential user services..."
systemctl --user enable hyprpolkitagent # If you decide to use this one
success "User services enabled."
press_enter_to_continue

# --- 5. COPY CONFIGURATION FILES ---
info "Copying configuration files..."
# This uses rsync for a robust copy. It creates parent directories and overwrites existing files.
# The structure assumes your dotfiles repo has folders like 'hypr', 'kitty', etc.
CONFIG_SOURCE_DIR="$(pwd)"
CONFIG_DEST_DIR="$HOME/.config"

# A list of all the config folders to copy
CONFIG_FOLDERS=(
  "hypr"
  "kitty"
  "waybar"
  "wofi"
  "dunst"
  "cava"
  "nvim"
  "p10k"
  "Thunar"
  "neofetch"
  "spicetify"
  "vivid"
  "xfce4"
  # Add other .config folders here
)

mkdir -p "$CONFIG_DEST_DIR"
for folder in "${CONFIG_FOLDERS[@]}"; do
  if [ -d "$CONFIG_SOURCE_DIR/$folder/.config/$folder" ]; then
    info "Copying $folder configuration..."
    mkdir -p "$CONFIG_DEST_DIR/$folder/"
    rsync -av --delete "$CONFIG_SOURCE_DIR/$folder/.config/$folder/" "$CONFIG_DEST_DIR/$folder/"
  else
    warn "Configuration for '$folder' not found in the expected structure. Skipping."
  fi
done

# Copying files from the root of the home directory (like .zshrc)
info "Copying Zsh and p10k configurations to home directory..."
rsync -av "$CONFIG_SOURCE_DIR/zsh/." "$HOME/"
rsync -av "$CONFIG_SOURCE_DIR/vscodium/." "$HOME/"
mkdir -p "$HOME/.themes"
rsync -av "$CONFIG_SOURCE_DIR/assets/themes/." "$HOME/.themes"
mkdir -p "$HOME/.local/share/icons"
rsync -av "$CONFIG_SOURCE_DIR/assets/icons/." "$HOME/.local/share/icons"
mkdir -p "$HOME/.local/share/fonts"
rsync -av "$CONFIG_SOURCE_DIR/assets/fonts/." "$HOME/.local/share/fonts"

success "Configuration files copied."
press_enter_to_continue

# --- 6. INSTALL GRUB THEME (OPTIONAL) ---
if [[ "$CONFIGURE_GRUB" == "y" || "$CONFIGURE_GRUB" == "Y" ]]; then
  info "Installing and configuring GRUB theme..."
  # This assumes you have a 'grub' folder in your dotfiles
  if [ -d "grub" ]; then
    sudo cp -r grub/* /boot/grub/themes/
    # Define the theme path and the config file
    THEME_PATH="/boot/grub/themes/lain/theme.txt"
    CONFIG_FILE="/etc/default/grub"

    # Check if a GRUB_THEME line already exists (commented or not)
    if grep -q "^#\?GRUB_THEME=" "$CONFIG_FILE"; then
      # If it exists, use sed to find that line (whether it's commented or not)
      # and replace it with the new, correct, uncommented line.
      sudo sed -i "s|^#\?GRUB_THEME=.*|GRUB_THEME=\"$THEME_PATH\"|" "$CONFIG_FILE"
    else
      # If the line does not exist at all, append it to the end of the file.
      echo "GRUB_THEME=\"$THEME_PATH\"" | sudo tee -a "$CONFIG_FILE"
    fi
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    success "GRUB theme installed."
  else
    warn "GRUB theme folder not found in dotfiles. Skipping."
  fi
else
  info "Skipping GRUB theme installation as requested."
fi
press_enter_to_continue

# --- 7. FINAL TOUCHES ---
info "Applying final touches..."

# Set hostname
# sudo hostnamectl set-hostname "$HOSTNAME"

# Change default shell to Zsh
if [ "$SHELL" != "/bin/zsh" ]; then
  if chsh -s $(which zsh); then
    success "Default shell changed to Zsh."
  else
    error "Failed to change shell. Please do it manually with 'chsh -s $(which zsh)'."
  fi
else
  success "Zsh is already the default shell."
fi

sh "$HOME/.config/hypr/scripts/apply-theme.sh" "everforest_dark"

success "Final touches complete."

# --- 8. FINISH ---
success "Your beautiful Hyprland desktop is now fully installed!"
info "It is highly recommended to REBOOT your system now to ensure all changes take effect."
echo "Thank you for using this script!"
