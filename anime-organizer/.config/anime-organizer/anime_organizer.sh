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

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  log "Error: Config file not found at $CONFIG_FILE"
  exit 1
fi

SOURCE_DIRS=("$DOWNLOADS_DIR" "$LOCALANIME_DIR")
# --- End of Configuration ---

log "Starting anime library scan... (Symlink Mode for Arch Linux)"

mkdir -p "$LIBRARY_DIR"

# --- Clean-up Phase ---
log "Authoritative cleanup: removing broken links and empty directories..."
find "$LIBRARY_DIR" -type l -xtype l -delete
find "$LIBRARY_DIR" -mindepth 1 -type d -empty -delete
# --- End of Clean-up Phase ---

# --- Symlink Generation Phase ---
for SOURCE in "${SOURCE_DIRS[@]}"; do

  if [ ! -d "$SOURCE" ]; then
    log "Warning: Source directory not found at $SOURCE. Skipping..."
    continue
  fi

  log "Scanning source: $SOURCE"

  find "$SOURCE" -type f \( -name "*.mp4" -o -name "*.mkv" \) | while IFS= read -r video_path; do

    video_filename=$(basename "$video_path")
    filename_no_ext="${video_filename%.*}"

    parent_dir_path=$(dirname "$video_path")
    parent_dir_name=$(basename "$parent_dir_path")

    grandparent_dir_path=$(dirname "$parent_dir_path")
    grandparent_dir_name=$(basename "$grandparent_dir_path")

    # --- Structure Detection Logic ---
    # Case 1: Downloads Structure (Anime Name / Episode 1 / Episode 1.mp4)
    if [ "$filename_no_ext" == "$parent_dir_name" ]; then
      anime_folder_name="$grandparent_dir_name"

    # Case 2: Standard/Local Structure (Anime Name / 01.mp4)
    else
      anime_folder_name="$parent_dir_name"
    fi
    # --- End of Structure Detection ---

    # Ignore list check
    IGNORE_FILE="$HOME/.config/anime-organizer/.ignore"
    if [ -f "$IGNORE_FILE" ] && grep -qxF "$anime_folder_name" "$IGNORE_FILE"; then
      continue
    fi

    # Extract episode number (grabs the last sequence of numbers)
    episode_number=$(echo "$filename_no_ext" | grep -oE '[0-9]+' | tail -n 1)

    # If no number is found in the filename, skip it
    if [ -z "$episode_number" ]; then
      continue
    fi

    # Clean up the anime title
    anime_title=$(echo "$anime_folder_name" | sed 's/\[[^]]*\]//g' | sed 's/ *$//')

    extension="${video_path##*.}"
    printf -v formatted_episode_number "%02d" "$episode_number"

    new_filename="${formatted_episode_number}.${extension}"

    anime_library_path="$LIBRARY_DIR/$anime_title"
    mkdir -p "$anime_library_path"

    symlink_path="$anime_library_path/$new_filename"

    if [ ! -e "$symlink_path" ]; then
      ln -s "$video_path" "$symlink_path"
      log "Created link: $anime_title - $new_filename"
    fi

  done
done

log "Scan complete! Check your library in '$LIBRARY_DIR'"
