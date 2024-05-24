#!/bin/bash

# Change directory to the location of the script
cd "$(dirname "${BASH_SOURCE[0]}")"

# Define the path to the dotfiles repository
dotfiles_repo_path="~/.dotfiles/config"

# Function to create symlinks and handle existing folders
create_symlinks() {
    for config_folder in "$dotfiles_repo_path/config/"*; do
        folder_name=$(basename "$config_folder")
        target_folder="$HOME/.config/$folder_name"
        
        if [ -e "$target_folder" ]; then
            # Backup existing folder
            backup_folder="$HOME/.config/backup_$folder_name"
            echo "Backing up existing $target_folder to $backup_folder"
            mv "$target_folder" "$backup_folder"
        fi

        # Create symlink
        ln -s "$config_folder" "$target_folder"
        echo "Creating symlink for $folder_name"
    done
}

# Run the function to create symlinks
create_symlinks

# Check for changes, commit, and push to the repository
git -C "$dotfiles_repo_path" add -A
git -C "$dotfiles_repo_path" diff --quiet || git -C "$dotfiles_repo_path" commit -m "Update dotfiles"
git -C "$dotfiles_repo_path" push origin master

