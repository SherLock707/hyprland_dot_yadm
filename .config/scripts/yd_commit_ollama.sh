#!/bin/bash

# Get the current timestamp
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')

# echo -e "\e[34m🚀 Starting YADM backup...\e[0m"

# Add all tracked files
# echo -e "\e[32m📂 Staging changes...\e[0m"
yadm add -u

# Get the staged changes
staged_changes=$(yadm diff --staged --name-only)

# Check if there are any changes to commit
if [ -z "$staged_changes" ]; then
  # echo -e "\e[33mℹ️ No changes to commit.\e[0m"
  exit 0
fi

staged_changes=$(echo "$staged_changes" | tr -d '\n')

# echo -e "\e[34m💬 Generating commit message using Ollama...\e[0m"

# Define the Ollama API endpoint
OLLAMA_API="http://localhost:11434/api/generate"

# Define the prompt for Ollama
prompt="Summarize the following changes and suggest a concise and meaningful commit message:$staged_changes"

# Define the prompt for Ollama - asking for a short message
prompt="Provide ONLY a very short, natural sounding and concise commit message summarizing these changes based on folders mainly (ideally under 50 characters). No formating of any kind. Changes: $staged_changes."

# Call Ollama API to get the commit message
response=$(curl -s -X POST -H "Content-Type: application/json" -d '{
  "model": "gemma3:latest",
  "prompt": "'"$prompt"'",
  "temperature": 0.1,
  "stream": false
}' "$OLLAMA_API")

# Extract the generated commit message
commit_message=$(echo "$response" | jq -r '.response')

# Clean up the commit message (remove leading/trailing whitespace)
commit_message=$(echo "$commit_message")

echo $commit_message

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
