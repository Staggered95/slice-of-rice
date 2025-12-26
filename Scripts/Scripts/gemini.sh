#!/bin/bash

# Check for API key
if [ -z "$GEMINI_API_KEY" ]; then
    echo "Error: GEMINI_API_KEY is not set."
    exit 1
fi

# Combine all arguments into a single prompt string
PROMPT="$*"

# API URL with the correct model name for the free tier
API_URL="https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}"

# Create the JSON payload
JSON_PAYLOAD=$(jq -n --arg prompt "$PROMPT" \
  '{ "contents": [ { "parts": [ { "text": $prompt } ] } ] }')
  
# Make the API call, parse the response, and store it in a variable
AI_RESPONSE=$(curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" "$API_URL" | jq -r '.candidates[0].content.parts[0].text')

# Check if the response is not null or empty
if [ -n "$AI_RESPONSE" ] && [ "$AI_RESPONSE" != "null" ]; then
    # Print the response wrapped in a Markdown code block for better rendering
    printf -- '```markdown\n%s\n```\n' "$AI_RESPONSE"
else
    # Handle cases where the API might return an empty or null response
    printf -- '```markdown\n%s\n```\n' "I received an empty response. Please try again."
fi
