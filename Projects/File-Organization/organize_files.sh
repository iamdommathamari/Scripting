#!/bin/bash
# This script organizes files in a directory by their extensions.
# Usage: ./organize_files.sh
# author: Mohith Dommathamari

read -p "Enter the directory to organize: " DIR

cd "$DIR" || { echo "Directory not found!"; exit 1; }

for FILE in *; do
    # Skip . and ..
    [[ "$FILE" == "." || "$FILE" == ".." ]] && continue
    # Skip directories
    [ -d "$FILE" ] && continue

    # Extract extension
    EXT="${FILE##*.}"
    # Handle files without extension or hidden files without extension
    if [[ "$FILE" != *.* ]] || [[ "$FILE" == .* && "$FILE" != *.*.* ]]; then
        EXT="no_extension"
    fi

    # Create extension folder if it doesn't exist
    mkdir -p "$EXT"

    # Move file without overwriting
    mv -n "$FILE" "$EXT/"
done

echo "Files organized by extension!"
