#!/bin/bash
# Enhanced File Organization Script
# This script organizes files in a directory by their extensions or dates.
# Usage: ./enhance_organize.sh
# author: Mohith Dommathamari

LOGFILE="organizer_audit.log"

read -p "Enter the directory to organize: " DIR
if [ ! -d "$DIR" ]; then
  echo "Directory not found!"
  exit 1
fi

# Menu for organization method
echo "How do you want to organize?"
select METHOD in "By Extension" "By Modified Date" "By Creation Date" "Exit"; do
    case $REPLY in
      1) ORGANIZE_TYPE="ext"; break;;
      2) ORGANIZE_TYPE="mod"; break;;
      3) ORGANIZE_TYPE="cre"; break;;
      4) exit 0;;
      *) echo "Invalid option";;
    esac
done

# Process all files recursively
find "$DIR" -type f | while read -r FILE; do
    # Choose target subdirectory based on method
    case $ORGANIZE_TYPE in
      ext)
        EXT="${FILE##*.}"
        [ "$EXT" = "$FILE" ] && EXT="no_extension"
        TARGET_DIR="$(dirname "$FILE")/$EXT"
        ;;
      mod)
        MOD_DATE=$(stat -c %y "$FILE" 2>/dev/null | cut -d' ' -f1 | cut -d'-' -f1,2)
        [ -z "$MOD_DATE" ] && MOD_DATE="unknown_date"
        TARGET_DIR="$(dirname "$FILE")/$MOD_DATE"
        ;;
      cre)
        # stat -c %w only works for some filesystems; fall back to mod date if blank
        CRE_DATE=$(stat -c %w "$FILE" 2>/dev/null | cut -d' ' -f1 | cut -d'-' -f1,2)
        [ -z "$CRE_DATE" -o "$CRE_DATE" = "-" ] && CRE_DATE=$(stat -c %y "$FILE" | cut -d' ' -f1 | cut -d'-' -f1,2)
        [ -z "$CRE_DATE" ] && CRE_DATE="unknown_date"
        TARGET_DIR="$(dirname "$FILE")/$CRE_DATE"
        ;;
    esac

    mkdir -p "$TARGET_DIR"
    mv -n "$FILE" "$TARGET_DIR/"
    echo "Moved $FILE -> $TARGET_DIR/ at $(date)" >> "$LOGFILE"
done

echo "Files organized by $([ "$ORGANIZE_TYPE" = "ext" ] && echo extension || echo date)! Actions logged in $LOGFILE."
