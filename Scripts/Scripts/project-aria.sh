#!/bin/bash
set -e

#==============================================================================
#                             Aria Journal Script
#==============================================================================

# --- DISPLAY HEADER ---
# Check if toilet command exists
if command -v figlet &>/dev/null; then
  # Use toilet with a blocky font and the metal/gay filters for a cool effect
  figlet "Project Aria"
else
  # Fallback to a simple text header if toilet is not installed
  echo "--- Aria Journal ---"
fi
# Add a newline for spacing
echo ""
# --- END HEADER ---
sleep 1
# --- CONFIGURATION ---
# The local directory of your 'Aria' Git repository.
PROJECT_DIR="$HOME/Aria"

# Your preferred text editor. Uses the system's $EDITOR variable if set, otherwise defaults to nvim.
EDITOR="nvim"

# The template for new notes. Use '\n' for new lines.
# The script will automatically add the current date under the //head tag.
TEMPLATE_CONTENT="## WHAT THEY DID?\n\n\n## WHAT I DID?\n\n\n## DESCRIPTION\n\n\n## Rating out of 10.0\nRating: X/10.0\n\n\n## EXPECTATIONS FROM TOMORROW / PLANS\n\n"
# --- END CONFIGURATION ---

# --- SCRIPT LOGIC ---

# Ensure the project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: Project directory not found at '$PROJECT_DIR'."
  exit 1
fi

# Change to the project directory
cd "$PROJECT_DIR" || exit

# --- STATE-AWARE FILENAME LOGIC ---
# Generate the date suffix for today's file (e.g., 27Sep25)
DATE_SUFFIX=$(date +'%d%b%y')

# First, check if a file for today's date already exists to avoid creating a new day number.
EXISTING_FILE_TODAY=$(find . -maxdepth 1 -type f -name "*_${DATE_SUFFIX}.aria" | head -n 1)

if [ -n "$EXISTING_FILE_TODAY" ]; then
  # A file for today already exists, use it.
  FILENAME=$(basename "$EXISTING_FILE_TODAY")
  FILE_PATH="$PROJECT_DIR/$FILENAME"
  echo "Opening existing note for today: $FILENAME"
else
  # No file for today exists, so we create a new one with an incremented day number.
  # Find the latest day number by parsing existing filenames.
  LATEST_DAY_NUM=$(ls -1 Day*_*.aria 2>/dev/null | sed -n 's/^Day\([0-9]\+\)_.*/\1/p' | sort -rn | head -n 1)

  if [ -z "$LATEST_DAY_NUM" ]; then
    # This is the very first note.
    DAY_NUM=1
  else
    # Increment the latest day number.
    DAY_NUM=$((LATEST_DAY_NUM + 1))
  fi

  FILENAME="Day${DAY_NUM}_${DATE_SUFFIX}.aria"
  FILE_PATH="$PROJECT_DIR/$FILENAME"

  echo "Creating new note: $FILENAME"
  # Create the file and populate it with the template
  printf "$TEMPLATE_CONTENT" >"$FILE_PATH"
  # Add the current date under the //head tag using sed
  sed -i "/\/\/head/a## $(date +'%A, %B %d, %Y')\n" "$FILE_PATH"
fi
# --- END FILENAME LOGIC ---

# If arguments are provided, add them as a new event
if [ "$#" -gt 0 ]; then
  MESSAGE="$*"
  # Format the message as a bullet point and add it under the //events tag
  EVENT_ENTRY="- $(date +'%H:%M') :: $MESSAGE"
  sed -i "/\/\/events/a$EVENT_ENTRY" "$FILE_PATH"
  echo "Logged new event: \"$MESSAGE\""
fi

# Open the note in the configured editor for manual changes
$EDITOR "$FILE_PATH"

# --- GIT OPERATIONS ---

# Check for changes in the git repository
if [ -n "$(git status --porcelain)" ]; then
  echo "Changes detected."
  read -p "Push changes to GitHub? (y/N) " confirm
  if [[ "$confirm" =~ ^[yY](es)?$ ]]; then
    echo "Adding, committing, and pushing to GitHub..."
    git add "$FILE_PATH"
    read -p "Enter the commit message: " brief
    git commit -m "$brief"
    git push origin main # Or your default branch
    echo "✅ Successfully pushed to GitHub."
  else
    echo "Changes saved locally. Not pushing to GitHub."
  fi
else
  echo "No changes to push."
fi

# --- ADVANCED INTEGRATION HOOK ---
# You can add a call to kotofetch or other summary tools here
