#!/bin/bash
# Enhanced Backup Script – August 2025
# Author: Your Name

set -euo pipefail

CONFIG="backup.conf"
LOGFILE="backup.log"
DRY_RUN=false

# ===== Color Codes =====
NC="\033[0m"
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"

# ===== Logging Functions =====
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; echo "$(date): $1" >> "$LOGFILE"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; echo "$(date): WARN: $1" >> "$LOGFILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; echo "$(date): ERROR: $1" >> "$LOGFILE"; }

# ===== Utility: Load config or defaults =====
if [[ -f "$CONFIG" ]]; then
    # shellcheck source=backup.conf
    source "$CONFIG"
fi

[[ -z "${RETENTION_DAYS:-}" ]] && RETENTION_DAYS=7
[[ -z "${EMAIL:-}" ]] && EMAIL=""
[[ -z "${ENCRYPT:-}" ]] && ENCRYPT=false
[[ -z "${GPG_RECIP:-}" ]] && GPG_RECIP=""
[[ -z "${REMOTE_ENABLE:-}" ]] && REMOTE_ENABLE=false
[[ -z "${REMOTE_METHOD:-}" ]] && REMOTE_METHOD="scp"
[[ -z "${REMOTE_PATH:-}" ]] && REMOTE_PATH=""
[[ -z "${EXCLUDES:-}" ]] && EXCLUDES=()
[[ -z "${COMPRESSION:-}" ]] && COMPRESSION="gzip"
[[ -z "${DRY_RUN:-}" ]] && DRY_RUN=false

# ===== Menu or CLI argument/Config fallback for sources/dest =====
if [[ "${#SOURCES[@]:-0}" -eq 0 ]]; then
    echo "Select backup type:"
    select TYPE in "Single Directory" "Multiple Directories" "Restore" "Dry Run" "Exit"; do
        case $REPLY in
            1) read -rp "Enter the directory to back up: " SRC; SOURCES=("$SRC"); break;;
            2) read -arp "Enter space-separated list of dirs: " SOURCES; break;;
            3)
                read -rp "Enter backup file to restore: " RESTORE_FILE
                read -rp "Enter extraction directory: " RESTORE_DEST
                mkdir -p "$RESTORE_DEST"
                tar -xzvf "$RESTORE_FILE" -C "$RESTORE_DEST"
                log_ok "Restored $RESTORE_FILE to $RESTORE_DEST"
                exit 0
                ;;
            4) DRY_RUN=true; break;;
            5) exit 0;;
            *) echo "Invalid option";;
        esac
    done
fi
if [[ -z "${DEST_DIR:-}" ]]; then
    read -rp "Enter backup destination directory: " DEST_DIR
fi
mkdir -p "$DEST_DIR"
if [[ "$DRY_RUN" = true ]]; then log_warn "DRY RUN - No data will be written."; fi

# ===== Compression Selection =====
case "$COMPRESSION" in
    "gzip")   TAR_EXT="tar.gz"; TAR_OPT="z";;
    "bzip2")  TAR_EXT="tar.bz2"; TAR_OPT="j";;
    "xz")     TAR_EXT="tar.xz";  TAR_OPT="J";;
    *)        TAR_EXT="tar.gz";  TAR_OPT="z";;
esac

# ===== Backup Loop =====
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_RESULTS=()
for SRC in "${SOURCES[@]}"; do
    BASE="$(basename "$SRC")"
    BACKUP_NAME="backup_${BASE}_${DATE}.${TAR_EXT}"
    BACKUP_PATH="$DEST_DIR/$BACKUP_NAME"
    EXC_ARGS=()
    for PAT in "${EXCLUDES[@]}"; do EXC_ARGS+=("--exclude=$PAT"); done

    if [ "$DRY_RUN" = true ]; then
        log_warn "Would back up $SRC to $BACKUP_PATH (dry run)"
        continue
    fi

    tar -c${TAR_OPT}f "$BACKUP_PATH" "${EXC_ARGS[@]}" -C "$(dirname "$SRC")" "$BASE" 2>>"$LOGFILE" \
        && log_ok "Backup complete: $BACKUP_NAME" \
        || { log_error "Failed backup: $SRC"; continue; }

    # Integrity check
    if tar -t${TAR_OPT}f "$BACKUP_PATH" > /dev/null 2>&1; then
        log_ok "Archive verified: $BACKUP_PATH"
    else
        log_error "Integrity check failed: $BACKUP_PATH"
        continue
    fi

    # Optional encryption
    if $ENCRYPT; then
        gpg --yes --output "${BACKUP_PATH}.gpg" --encrypt --recipient "$GPG_RECIP" "$BACKUP_PATH" \
            && rm "$BACKUP_PATH" \
            && BACKUP_PATH="${BACKUP_PATH}.gpg" \
            && log_ok "Encrypted archive: $BACKUP_PATH"
    fi
    BACKUP_RESULTS+=("SUCCESS: $SRC -> $BACKUP_PATH")
done

# ===== Retention =====
find "$DEST_DIR" -type f \( -name "backup_*.tar.*" -o -name "backup_*.tar.*.gpg" \) -mtime +"$RETENTION_DAYS" -exec rm -f {} \; -exec echo "$(date): Deleted old backup {}" >> "$LOGFILE" \;

# ===== Remote Copy =====
if $REMOTE_ENABLE && [ -n "$REMOTE_PATH" ]; then
    for RESULT in "${BACKUP_RESULTS[@]}"; do
        [[ $RESULT = SUCCESS* ]] || continue
        FILE_PATH=$(echo "$RESULT" | awk '{print $4}')
        if [ "$REMOTE_METHOD" = "scp" ]; then
            scp "$FILE_PATH" "$REMOTE_PATH" \
              && log_ok "Remote copy OK: $FILE_PATH"
        elif [ "$REMOTE_METHOD" = "rclone" ]; then
            rclone copy "$FILE_PATH" "$REMOTE_PATH" \
              && log_ok "Rclone copy OK: $FILE_PATH"
        fi
    done
fi

# ===== Email Notification =====
if [[ -n "$EMAIL" ]]; then
    MAIL_BODY="Backup Report ($(date))\n$(printf '%s\n' "${BACKUP_RESULTS[@]}")"
    echo -e "$MAIL_BODY" | mail -s "Backup Script Report: $DATE" "$EMAIL"
    log_ok "Email report sent to $EMAIL."
fi

echo -e "${YELLOW}Backups completed. See $LOGFILE for details.${NC}"
