#!/bin/bash

# Get the current timestamp
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')

# echo -e "\e[34m🚀 Starting YADM backup...\e[0m"

# Add all tracked files
# echo -e "\e[32m📂 Staging changes...\e[0m"
yadm add -u

# Get the actual staged diff (the contents of the changes)
# We truncate to the first 1000 characters so Ollama doesn't hang on massive diffs!
staged_changes=$(yadm diff --staged | head -c 1000)

# Check if there are any changes to commit
if [ -z "$staged_changes" ]; then
  echo '{"valid": false, "message": "No changes to commit"}'
  exit 0
fi

# Replace newlines with spaces so filenames don't merge together
staged_changes=$(echo "$staged_changes" | tr '\n' ' ')

# echo -e "\e[34m💬 Generating commit message using Ollama...\e[0m"

# Define the Ollama API endpoint
OLLAMA_API="http://localhost:11434/api/generate"

# Define the prompt for Ollama
prompt="Summarize the following changes and suggest a concise and meaningful commit message:$staged_changes"

# Define the prompt for Ollama - asking for a short message based on the diff
prompt="You are an expert developer. Provide ONLY a very short, natural sounding and concise commit message summarizing these git diff changes (ideally under 50 characters). No formatting, no markdown, no explanation. Just the commit message. Changes:
$staged_changes"

# Safely build the JSON payload using jq to prevent syntax errors if filenames have quotes
JSON_PAYLOAD=$(jq -n \
  --arg prompt "$prompt" \
  '{
    "model": "llama3.2:1b",
    "prompt": $prompt,
    "temperature": 0.1,
    "stream": false
  }')

# Call Ollama API to get the commit message
response=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON_PAYLOAD" "$OLLAMA_API")

# Check for API errors
api_error=$(echo "$response" | jq -r '.error // empty')
if [ -n "$api_error" ]; then
  jq -n --arg msg "Ollama Error: $api_error" '{"valid": false, "message": $msg}'
  exit 1
fi

# Extract the generated commit message
commit_message=$(echo "$response" | jq -r '.response')

# Clean up the commit message (remove leading/trailing whitespace properly)
commit_message=$(echo "$commit_message" | xargs)

# Output success JSON
jq -n --arg msg "$commit_message" '{"valid": true, "message": $msg}'

# # --- Commit with generated message or fallback ---
# echo -e "\e[33m📝 Committing changes...\e[0m"

# if [ -n "$commit_message" ]; then
#   echo -e "\e[32m✅ Using generated commit message: \e[1m$commit_message\e[0m"
# #   yadm commit -m "$commit_message"
# else
#   echo -e "\e[31m⚠️ Failed to generate commit message. Using default timestamp.\e[0m"
# #   yadm commit -m "commit - $timestamp"
# fi

# # Push changes
# echo -e "\e[35m📤 Pushing to remote...\e[0m"
# # yadm push

# echo -e "\e[36m✅ Backup complete!\e[0m"
