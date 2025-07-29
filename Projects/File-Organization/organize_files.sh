#!/bin/bash
# This script organizes files in a directory by their extensions.
# Usage: ./organize_files.sh
# Ensure the script is run in a directory with files to organize.
# author: Mohith Dommathamari

read -p "Enter the directory to organize: " DIR

cd "$DIR" || { echo "Directory not found!"; exit 1; }

for FILE in *; do
    # Skip folders
    [ -d "$FILE" ] && continue

    # Extract file extension, handle hidden files without extension
    if [[ "$FILE" == .* && "$FILE" != *.* ]]; then
        EXT="no_extension"
    [ "$EXT" = "$FILE" ] && EXT="no_extension"
        EXT="${FILE##*.}"
        [ "$EXT" == "$FILE" ] && EXT="no_extension"
    fi

    # Create folder if not exists
    mkdir -p "$EXT"

    mv -n "$FILE" "$EXT/"
done

echo "Files organized by extension!"