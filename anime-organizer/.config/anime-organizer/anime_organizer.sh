#!/bin/bash

# --- Logging Setup ---
LOG_DIR="$HOME/.local/state/anime_organizer"
LOG_FILE="$LOG_DIR/organizer.log"
mkdir -p "$LOG_DIR"
# --- End of Logging Setup ---

log() {
  echo "$1" | tee -a "$LOG_FILE"
}

# --- Configuration ---
CONFIG_FILE="$HOME/.config/anime-organizer/organizer.conf"

# Load config file if it exists
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  log "Error: Config file not found at $CONFIG_FILE"
  exit 1
fi
# --- End of Configuration ---

log "Starting anime library scan... (Symlink Mode for Arch Linux)"

if [ ! -d "$DOWNLOADS_DIR" ]; then
  log "Error: Download directory not found at $DOWNLOADS_DIR"
  exit 1
fi

mkdir -p "$LIBRARY_DIR"

find "$DOWNLOADS_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" \) | while IFS= read -r video_path; do

  video_filename=$(basename "$video_path")
  filename_no_ext="${video_filename%.*}"

  episode_folder_path=$(dirname "$video_path")
  episode_folder_name=$(basename "$episode_folder_path")

  # --- THIS IS THE MOVED BLOCK ---
  # We define anime_folder_name and then immediately check if we should ignore it.
  anime_folder_path=$(dirname "$episode_folder_path")
  anime_folder_name=$(basename "$anime_folder_path")

  IGNORE_FILE="$HOME/.config/anime-organizer/.ignore"
  if [ -f "$IGNORE_FILE" ] && grep -qxF "$anime_folder_name" "$IGNORE_FILE"; then
    continue # Skip to the next file
  fi
  # --- END OF MOVED BLOCK ---

  if [ "$filename_no_ext" == "$episode_folder_name" ]; then

    episode_number=$(echo "$filename_no_ext" | sed 's/[^0-9]*//g')

    if [ -z "$episode_number" ]; then
      continue
    fi

    # We already have anime_folder_name, so no need to define it again.
    anime_title=$(echo "$anime_folder_name" | sed 's/\[[^]]*\]//g' | sed 's/ *$//')

    extension="${video_path##*.}"
    printf -v formatted_episode_number "%02d" "$episode_number"
    #uncomment if you want anime title as well
    #new_filename="$anime_title - S01E$formatted_episode_number.$extension"
    new_filename="$formatted_episode_number.$extension"

    anime_library_path="$LIBRARY_DIR/$anime_title"
    mkdir -p "$anime_library_path"

    symlink_path="$anime_library_path/$new_filename"

    if [ ! -e "$symlink_path" ]; then
      ln -s "$video_path" "$symlink_path"
      log "Created link: $new_filename"
    fi
  fi
done

log "Scan complete! Check your library in '$LIBRARY_DIR'"
