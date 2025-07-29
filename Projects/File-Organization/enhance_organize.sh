#!/bin/bash
# Enhanced File Organizer Script - Modular Version
# Organize files by extension, modification date, or creation date (recursive)
# Logs all actions for auditing.
# Usage: ./enhance_organize.sh
# author: Mohith Dommathamari

LOGFILE="organizer_audit.log"

prompt_directory() {
  read -p "Enter the directory to organize: " DIR
  if [ ! -d "$DIR" ]; then
    echo "Directory not found!"
    exit 1
  fi
}

choose_method() {
  echo "How do you want to organize?"
  select METHOD in "By Extension" "By Date Modified" "By Date Created" "Exit"; do
    case $REPLY in
      1) ORGANIZE_TYPE="ext"; break;;
      2) ORGANIZE_TYPE="mod"; break;;
      3) ORGANIZE_TYPE="cre"; break;;
      4) exit 0;;
      *) echo "Invalid option";;
    esac
  done
}

get_target_dir() {
  FILE="$1"
  case $ORGANIZE_TYPE in
    ext)
      EXT="${FILE##*.}"
      [ "$EXT" = "$FILE" ] && EXT="no_extension"
      echo "$(dirname "$FILE")/$EXT"
      ;;
    mod)
      MOD_DATE=$(stat -c %y "$FILE" 2>/dev/null | cut -d' ' -f1 | cut -d'-' -f1,2)
      [ -z "$MOD_DATE" ] && MOD_DATE="unknown_date"
      echo "$(dirname "$FILE")/$MOD_DATE"
      ;;
    cre)
      CRE_DATE=$(stat -c %w "$FILE" 2>/dev/null | cut -d' ' -f1 | cut -d'-' -f1,2)
      [ -z "$CRE_DATE" -o "$CRE_DATE" = "-" ] && CRE_DATE=$(stat -c %y "$FILE" | cut -d' ' -f1 | cut -d'-' -f1,2)
      [ -z "$CRE_DATE" ] && CRE_DATE="unknown_date"
      echo "$(dirname "$FILE")/$CRE_DATE"
      ;;
  esac
}

log_action() {
  ACTION="$1"
  echo "$ACTION at $(date)" >> "$LOGFILE"
}

organize_files() {
  find "$DIR" -type f | while read -r FILE; do
    TARGET_DIR="$(get_target_dir "$FILE")"
    mkdir -p "$TARGET_DIR"
    BASENAME="$(basename "$FILE")"
    mv -n "$FILE" "$TARGET_DIR/"
    log_action "Moved $FILE -> $TARGET_DIR/$BASENAME"
  done
}

# ========== Main Script ==========

prompt_directory
choose_method
organize_files

echo "Files organized by $([ "$ORGANIZE_TYPE" = "ext" ] && echo 'extension' || echo 'date')!"
echo "Audit log: $LOGFILE"
