#!/bin/bash
# Automated Backup Tool by Mohith Dommathamari
# This script creates a compressed backup of a specified directory.
# Usage: ./backup_tool.sh

#=========================#
# Configuration & Colors  #
#=========================#
RETENTION_DAYS=7
LOGFILE="backup.log"

NC="\033[0m"          # No Color
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"

#=========================#
# 1. User Input           #
#=========================#

read -p "Enter the directory to back up: " SRC_DIR
read -p "Enter the backup destination directory: " DEST_DIR

#=========================#
# 2. Validation           #
#=========================#
if [ ! -d "$SRC_DIR" ]; then
  echo -e "${RED}Source directory does not exist!${NC}"
  exit 1
fi

mkdir -p "$DEST_DIR" || { echo -e "${RED}Cannot create/access destination directory!${NC}"; exit 1; }

#=========================#
# 3. Create Backup        #
#=========================#
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_NAME="backup_${DATE}.tar.gz"
BACKUP_PATH="$DEST_DIR/$BACKUP_NAME"

tar -czf "$BACKUP_PATH" -C "$SRC_DIR" . 2>>"$DEST_DIR/$LOGFILE"
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Backup successful: $BACKUP_NAME${NC}"
  echo "$(date): Backup successful: $BACKUP_NAME" >> "$DEST_DIR/$LOGFILE"
else
  echo -e "${RED}Backup failed! Check the log for details.${NC}"
  echo "$(date): Backup FAILED for $SRC_DIR" >> "$DEST_DIR/$LOGFILE"
  exit 1
fi

#=========================#
# 4. Retention Management #
#=========================#
find "$DEST_DIR" -name "backup_*.tar.gz" -type f -mtime +$RETENTION_DAYS -exec rm -f {} \; \
  -exec echo "$(date): Deleted old backup {}" >> "$DEST_DIR/$LOGFILE" \;

#=========================#
# 5. Final Notification   #
#=========================#
echo -e "${YELLOW}Backup complete. Archive saved as ${BACKUP_PATH}${NC}"

# Optional: Desktop notification (Linux, notify-send). Uncomment if needed.
# notify-send "Backup Tool" "Backup complete: $BACKUP_NAME"
