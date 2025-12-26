#!/bin/bash

# --- Colors & Variables ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# --- Helper Functions ---
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

press_enter_to_continue() {
  echo -e "${MAGENTA}Press ENTER to continue...${NC}"
  read -r
}

# ========================================================================================
#                                     MAIN SCRIPT
# ========================================================================================

sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done &>/dev/null &

# --- 1. GATHER USER INFORMATION ---
echo -e "${BLUE}Welcome to Slice-of-Rice installation (Stow Edition)${NC}"
press_enter_to_continue
read -p "Do you want to configure GRUB theme? (y/n): " CONFIGURE_GRUB
read -p "Do you want to install YT Music Vivaldi PWA? (y/n): " CONFIGURE_YTM

# --- 2. VERIFY PACKAGE LISTS ---
info "Verifying package lists..."
if [ ! -f "$SCRIPT_DIR/fresh/pkglist.txt" ] || [ ! -f "$SCRIPT_DIR/fresh/pkglist_aur.txt" ]; then
  error "Package lists not found in $SCRIPT_DIR/fresh/!"
fi
success "Package lists found."

# --- 3. INSTALL PACKAGES ---
info "Installing packages..."
sudo pacman -Syu --needed --noconfirm base-devel git stow
sudo pacman -Syu --needed --noconfirm - <"$SCRIPT_DIR/fresh/pkglist.txt"

info "Checking for AUR helper..."
if ! command -v yay &>/dev/null; then
  warn "'yay' not found. Installing..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
fi

info "Installing AUR packages..."
yay -S --needed --noconfirm - <"$SCRIPT_DIR/fresh/pkglist_aur.txt"

# --- 4. PREPARE & BACKUP VSCodium ---
# We do this BEFORE stowing to prevent conflicts
info "Checking VSCodium User config..."
VSCODE_USER_DIR="$HOME/.config/VSCodium/User"
mkdir -p "$VSCODE_USER_DIR"

# If real files exist (not symlinks), back them up so Stow doesn't fail
if [ -f "$VSCODE_USER_DIR/settings.json" ] && [ ! -L "$VSCODE_USER_DIR/settings.json" ]; then
  warn "Existing VSCodium settings found. Backing up..."
  mkdir -p "$BACKUP_DIR/VSCodium"
  mv "$VSCODE_USER_DIR/settings.json" "$BACKUP_DIR/VSCodium/"
  mv "$VSCODE_USER_DIR/keybindings.json" "$BACKUP_DIR/VSCodium/" 2>/dev/null
  success "VSCodium config backed up to $BACKUP_DIR"
fi

# --- 5. STOW CONFIGURATION FILES ---
info "Stowing configuration files..."

mkdir -p "$HOME/.config"

# List of stow packages
# NOTE: Ensure you have a 'Scripts' folder in your dotfiles repo for your ~/Scripts
STOW_FOLDERS=(
  "hypr" "kitty" "waybar" "wofi" "dunst" "cava"
  "nvim" "Thunar" "neofetch" "spicetify" "vivid" "xfce4"
  "zsh" "vscodium" "Scripts" "anime-organizer" "systemd"
)

cd "$SCRIPT_DIR" || error "Could not enter script directory"

for folder in "${STOW_FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    info "Stowing $folder..."

    # Conflict check: If a real config folder exists (not a symlink),
    # stow will fail. We must back it up first.
    TARGET_DIR="$HOME/.config/$folder"
    # Special case handling for folders that don't map to .config directly if needed
    if [ "$folder" == "Scripts" ]; then TARGET_DIR="$HOME/Scripts"; fi

    if [ -d "$TARGET_DIR" ] && [ ! -L "$TARGET_DIR" ]; then
      warn "Existing config found for $folder. Backing up..."
      mkdir -p "$BACKUP_DIR"
      mv "$TARGET_DIR" "$BACKUP_DIR/${folder}_bak"
    fi

    # -R (Restow) refreshes links
    stow -R -t "$HOME" "$folder"
  else
    warn "Folder '$folder' not found. Skipping."
  fi
done

# --- 6. ZSH AUTOSUGGESTIONS ---
info "Setting up Zsh Autosuggestions..."
ZSH_PLUGIN_DIR="$HOME/.zsh/zsh-autosuggestions"
if [ ! -d "$ZSH_PLUGIN_DIR" ]; then
  mkdir -p "$HOME/.zsh"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR"
  success "Zsh autosuggestions installed."
else
  success "Zsh autosuggestions already exists."
fi

# --- 7. ANIMIRU & SERVICES ---
info "Enabling system services..."
sudo systemctl enable --now sddm.service || warn "SDDM issue"
sudo systemctl enable --now NetworkManager.service || warn "NetworkManager issue"
sudo systemctl enable --now bluetooth.service || warn "Bluetooth issue"

info "Enabling user services (Animiru)..."
# Reload daemon to ensure it sees the new stowed unit files
systemctl --user daemon-reload
systemctl --user enable --now anime_organizer.timer || warn "Could not enable Anime Timer"
systemctl --user enable --now anime_organizer.service || warn "Could not enable Anime Service"
success "User services enabled."

# --- 8. GRUB THEME ---
if [[ "$CONFIGURE_GRUB" =~ ^[Yy]$ ]]; then
  info "Configuring GRUB..."
  if [ -d "grub" ]; then
    sudo mkdir -p /boot/grub/themes/
    sudo cp -r "grub/"* /boot/grub/themes/

    THEME_PATH="/boot/grub/themes/lain/theme.txt"
    CONFIG_FILE="/etc/default/grub"

    if grep -q "^GRUB_THEME=" "$CONFIG_FILE"; then
      sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$THEME_PATH\"|" "$CONFIG_FILE"
    elif grep -q "^#GRUB_THEME=" "$CONFIG_FILE"; then
      sudo sed -i "s|^#GRUB_THEME=.*|GRUB_THEME=\"$THEME_PATH\"|" "$CONFIG_FILE"
    else
      echo "GRUB_THEME=\"$THEME_PATH\"" | sudo tee -a "$CONFIG_FILE"
    fi

    sudo grub-mkconfig -o /boot/grub/grub.cfg
  else
    warn "GRUB folder not found."
  fi
fi

# --- 9. FINAL TOUCHES ---
info "Applying final touches..."

# YT Music Desktop File
if [[ "$CONFIGURE_YTM" =~ ^[Yy]$ ]]; then
  info "Installing YT Music Desktop file..."
  mkdir -p ~/.local/share/applications/
  if [ -f "others/youtube-music.desktop" ]; then
    cp "others/youtube-music.desktop" ~/.local/share/applications/
  else
    warn "youtube-music.desktop not found in 'others' folder."
  fi
fi

# Assets
info "Copying assets..."
mkdir -p "$HOME/.themes" "$HOME/.local/share/icons" "$HOME/.local/share/fonts"
[ -d "assets/themes" ] && rsync -av "assets/themes/" "$HOME/.themes/"
[ -d "assets/icons" ] && rsync -av "assets/icons/" "$HOME/.local/share/icons/"
[ -d "assets/fonts" ] && rsync -av "assets/fonts/" "$HOME/.local/share/fonts/"

# Change Shell
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)" || warn "Change shell manually."
fi

# Apply Theme
THEME_SCRIPT="$HOME/.config/hypr/scripts/apply-theme.sh"
if [ -f "$THEME_SCRIPT" ]; then
  chmod +x "$THEME_SCRIPT"
  "$THEME_SCRIPT" "everforest_dark"
fi

# Rebuild font cache
fc-cache -fv &>/dev/null

success "Slice-of-Rice installation complete!"
info "Backup of old configs stored in: $BACKUP_DIR"
info "Please reboot your system."
