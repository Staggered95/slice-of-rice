#!/bin/bash

# --- Configuration ---
HISTORY_FILE="$HOME/.gemini_history.json"

# Define ANSI colors
CYAN='\033[0;36m'
RESET='\033[0m' # Resets color to default

# This instruction is now much stricter to force shorter answers.
SYSTEM_INSTRUCTION="You are an elite command-line assistant for an Arch Linux expert. Be extremely brief. Prioritize one-line commands. Omit explanations unless explicitly asked. Your entire response should be 2-3 sentences maximum."


# --- Script Logic (No changes needed below until the final print statement) ---

# Check for a --reset flag to clear the history
if [[ "$1" == "--reset" ]]; then
    rm -f "$HISTORY_FILE"
    echo "Conversation history has been reset."
    exit 0
fi

# If the history file doesn't exist, create it and prime it with the system instruction.
if [ ! -f "$HISTORY_FILE" ]; then
    jq -n \
       --arg instruction "$SYSTEM_INSTRUCTION" \
       '[
         {"role": "user", "parts": [{"text": $instruction}]},
         {"role": "model", "parts": [{"text": "Understood."}]}
       ]' > "$HISTORY_FILE"
fi

# Check for API key
if [ -z "$GEMINI_API_KEY" ]; then
    echo "Error: GEMINI_API_KEY is not set."
    exit 1
fi

# The user's new prompt is all the script arguments combined
USER_PROMPT="$*"
if [ -z "$USER_PROMPT" ]; then
    echo "Usage: gemini-chat.sh <your prompt>"
    echo "   or: gemini-chat.sh --reset (to clear history)"
    exit 1
fi

# API URL
API_URL="https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}"

# JSON Payload Construction
JSON_PAYLOAD=$(jq -n \
                  --arg user_prompt "$USER_PROMPT" \
                  --slurpfile history "$HISTORY_FILE" \
                  '{
                    "contents": ($history[0] + [{"role": "user", "parts": [{"text": $user_prompt}]}]),
                    "generationConfig": {
                      "temperature": 0.7,
                      "topK": 1,
                      "topP": 1
                    }
                  }')

# API Call and Response Handling
API_RESPONSE=$(curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" "$API_URL")
MODEL_RESPONSE_TEXT=$(echo "$API_RESPONSE" | jq -r '.candidates[0].content.parts[0].text')

# Check for a valid response
if [ -z "$MODEL_RESPONSE_TEXT" ] || [ "$MODEL_RESPONSE_TEXT" == "null" ]; then
    echo "Error: Failed to get a response from the API."
    echo "Raw response:"
    echo "$API_RESPONSE"
    exit 1
fi

# Update History
jq \
    --arg user_prompt "$USER_PROMPT" \
    --arg model_response "$MODEL_RESPONSE_TEXT" \
    '. + [{"role": "user", "parts": [{"text": $user_prompt}]}, {"role": "model", "parts": [{"text": $model_response}]}]' \
    "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"


# --- Final Output ---
# This is the changed part: We removed the markdown and added the color codes.
printf "${CYAN}%s${RESET}\n" "$MODEL_RESPONSE_TEXT"
