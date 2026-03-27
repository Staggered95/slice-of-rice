#!/data/data/com.termux/files/usr/bin/bash

# --- CONFIGURATION LOADING ---
CONFIG_FILE="$HOME/.config/ani-sync/config.env"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Configuration not found. Please run setup.sh first."
  exit 1
fi

source "$CONFIG_FILE"
# -----------------------------

read -p "Enter Anime Name: " ANIME
if [ -z "$ANIME" ]; then
  echo "Anime name cannot be empty. Exiting."
  exit 1
fi

read -p "Enter Episode(s) (e.g., 5, 5-10) [Leave blank to select later]: " EP

echo "Select Audio:"
echo "0) Sub (default)"
echo "1) Dub"
read -p "Enter choice [0-1]: " AUD_CHOICE
if [ "$AUD_CHOICE" == "1" ]; then
  DUB_FLAG="--dub"
else
  DUB_FLAG=""
fi

echo "Select Quality:"
echo "0) best (default)"
echo "1) 1080p"
echo "2) 720p"
echo "3) 480p"
read -p "Enter choice [0-3]: " QUAL_CHOICE

case $QUAL_CHOICE in
1) QUAL="1080p" ;;
2) QUAL="720p" ;;
3) QUAL="480p" ;;
*) QUAL="best" ;;
esac

# Search for an existing folder, ignoring case
MATCHED_DIR=$(find "$BASE_DIR" -maxdepth 1 -mindepth 1 -type d -iname "$ANIME" -print -quit)

if [ -n "$MATCHED_DIR" ]; then
  TARGET_DIR="$MATCHED_DIR"
  echo "Found existing folder: $(basename "$TARGET_DIR")"
else
  TARGET_DIR="$BASE_DIR/$ANIME"
  echo "Creating new folder: $ANIME"
  mkdir -p "$TARGET_DIR"
fi

cd "$TARGET_DIR" || {
  echo "Failed to access directory."
  exit 1
}

echo "-----------------------------------"
echo "Target Folder: $TARGET_DIR"
echo "Quality: $QUAL | Audio: ${DUB_FLAG:---sub}"
echo "-----------------------------------"

if [ -z "$EP" ]; then
  ani-cli "$ANIME" -d -q "$QUAL" $DUB_FLAG
else
  ani-cli "$ANIME" -d -e "$EP" -q "$QUAL" $DUB_FLAG
fi

echo "Process finished."
