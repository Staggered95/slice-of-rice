#!/bin/bash

# --- A script to verify package lists ---

# Color Definitions
GREEN="\033[0;32m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"

# --- Check Official Repositories ---
echo -e "${CYAN}--- Checking pkglist.txt (Official Repositories) ---${NC}"
NOT_FOUND_PACMAN=false
for pkg in $(cat pkglist.txt); do
    if pacman -Si "$pkg" &> /dev/null; then
        echo -e "${GREEN}OK:${NC} $pkg"
    else
        echo -e "${RED}NOT FOUND:${NC} $pkg"
        NOT_FOUND_PACMAN=true
    fi
done

echo "" # Newline for spacing

# --- Check Arch User Repository (AUR) ---
echo -e "${CYAN}--- Checking pkglist_aur.txt (AUR) ---${NC}"
NOT_FOUND_YAY=false
for pkg in $(cat pkglist_aur.txt); do
    if yay -Si "$pkg" &> /dev/null; then
        echo -e "${GREEN}OK:${NC} $pkg"
    else
        echo -e "${RED}NOT FOUND:${NC} $pkg"
        NOT_FOUND_YAY=true
    fi
done

echo "" # Newline for spacing

# --- Final Summary ---
if [ "$NOT_FOUND_PACMAN" = true ] || [ "$NOT_FOUND_YAY" = true ]; then
    echo -e "${RED}Errors found. Please correct the 'NOT FOUND' packages in your lists.${NC}"
    exit 1
else
    echo -e "${GREEN}All packages verified successfully! Your lists are ready.${NC}"
fi
