#!/data/data/com.termux/files/usr/bin/bash

# --- CONFIGURATION LOADING ---
CONFIG_FILE="$HOME/.config/ani-sync/config.env"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Configuration not found. Please run setup.sh first."
  exit 1
fi

source "$CONFIG_FILE"
# -----------------------------

if [ ! -d "$BASE_DIR" ]; then
  echo "Directory not found: $BASE_DIR"
  exit 1
fi

while true; do
  dirs=()
  while IFS= read -r -d $'\0' dir; do
    dirs+=("$dir")
  done < <(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

  if [ ${#dirs[@]} -eq 0 ]; then
    echo "No anime folders found in $BASE_DIR."
    exit 0
  fi

  echo -e "\n==================================="
  echo "Available Anime:"
  for i in "${!dirs[@]}"; do
    folder_name=$(basename "${dirs[$i]}")
    echo "$i) $folder_name"
  done
  echo "==================================="

  read -p "Select anime to sync [0-$((${#dirs[@]} - 1))] or 'q' to quit: " choice

  if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
    echo "Exiting."
    break
  fi

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 0 ] || [ "$choice" -ge "${#dirs[@]}" ]; then
    echo "Invalid selection. Please try again."
    continue
  fi

  TARGET_DIR="${dirs[$choice]}"
  ANIME_NAME=$(basename "$TARGET_DIR")

  cd "$TARGET_DIR" || {
    echo "Failed to access directory."
    continue
  }

  FILE_COUNT=$(ls -1 *.mp4 *.mkv 2>/dev/null | wc -l)

  read -p "How many episodes to sync? [Press Enter for 1]: " SYNC_COUNT
  SYNC_COUNT=${SYNC_COUNT:-1}

  if ! [[ "$SYNC_COUNT" =~ ^[0-9]+$ ]] || [ "$SYNC_COUNT" -lt 1 ]; then
    echo "Invalid number. Defaulting to 1."
    SYNC_COUNT=1
  fi

  START_EP=$((FILE_COUNT + 1))

  # Corrected math block
  if [ "$SYNC_COUNT" -eq 1 ]; then
    EP_ARG="$START_EP"
    EP_DISPLAY="episode $START_EP"
  else
    END_EP=$((START_EP + SYNC_COUNT - 1))
    EP_ARG="$START_EP-$END_EP"
    EP_DISPLAY="episodes $START_EP to $END_EP"
  fi

  echo "-----------------------------------"
  echo "Syncing: $ANIME_NAME"
  echo "Currently downloaded: $FILE_COUNT episodes."
  echo "Targeting $EP_DISPLAY"
  echo "-----------------------------------"

  ani-cli "$ANIME_NAME" -d -e "$EP_ARG" -q "best"

  echo -e "\nSync complete for $EP_DISPLAY."

  read -p "Do you want to sync another anime? (y/n): " sync_again
  if [[ "$sync_again" != "y" && "$sync_again" != "Y" ]]; then
    echo "Done."
    break
  fi
done
