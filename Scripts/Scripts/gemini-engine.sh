#!/bin/bash
# FILE: ~/Scripts/gemini-engine.sh

# --- Configuration ---
# Read persona and history file from environment variables.
# The persona scripts ('dev', 'otaku') will set these.
if [ -z "$GEMINI_PERSONA" ] || [ -z "$GEMINI_HISTORY_FILE" ]; then
    echo "Error: This is the engine script. Run it via a persona script (e.g., 'dev' or 'otaku')."
    exit 1
fi

SYSTEM_INSTRUCTION="$GEMINI_PERSONA"
HISTORY_FILE="$GEMINI_HISTORY_FILE"

# Define ANSI colors
CYAN='\033[0;36m'
RESET='\033[0m'

# --- Script Logic ---
if [[ "$1" == "--reset" ]]; then
    rm -f "$HISTORY_FILE"
    echo "Conversation history for this persona has been reset."
    exit 0
fi

if [ ! -f "$HISTORY_FILE" ]; then
    jq -n --arg instruction "$SYSTEM_INSTRUCTION" \
        '[
         {"role": "user", "parts": [{"text": $instruction}]},
         {"role": "model", "parts": [{"text": "Understood."}]}
       ]' >"$HISTORY_FILE"
fi

if [ $# -gt 0 ]; then
    USER_PROMPT="$*"
else
    read -p "Ask Gemini: " USER_PROMPT
fi

if [ -z "$USER_PROMPT" ]; then
    exit 0
fi

API_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}"
JSON_PAYLOAD=$(jq -n --arg user_prompt "$USER_PROMPT" --slurpfile history "$HISTORY_FILE" \
    '{"contents": ($history[0] + [{"role": "user", "parts": [{"text": $user_prompt}]}])}')

API_RESPONSE=$(curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" "$API_URL")
MODEL_RESPONSE_TEXT=$(echo "$API_RESPONSE" | jq -r '.candidates[0].content.parts[0].text')

if [ -z "$MODEL_RESPONSE_TEXT" ] || [ "$MODEL_RESPONSE_TEXT" == "null" ]; then
    echo "Error: Failed to get a response from the API."
    echo "Raw response:"
    echo "$API_RESPONSE"
    exit 1
fi

jq --arg user_prompt "$USER_PROMPT" --arg model_response "$MODEL_RESPONSE_TEXT" \
    '. + [{"role": "user", "parts": [{"text": $user_prompt}]}, {"role": "model", "parts": [{"text": $model_response}]}]' \
    "$HISTORY_FILE" >"$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"

# Prints colored text wrapped in a markdown block
printf "${CYAN}´´´markdown\n%s\n´´´${RESET}\n" "$MODEL_RESPONSE_TEXT"
