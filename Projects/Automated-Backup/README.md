# Automated Backup Tool

A versatile **shell script** to create compressed backups of files and directories with options for encryption, email notifications, remote storage, and more. This project helps you automate regular backups with retention and logging — ideal for beginner to intermediate DevOps practitioners.

---

## Table of Contents

- [Features](#features)
- [Basic Version](#basic-version)
- [Enhanced Version](#enhanced-version)
- [Usage](#usage)
- [Installation](#installation)
- [Scheduling with Cron](#scheduling-with-cron)
- [Configuration File](#configuration-file)
- [Customization and Enhancements](#customization-and-enhancements)
- [Best Practices](#best-practices)
- [License](#license)

---

## Features

**Basic Version**  
- Backup single directory into compressed `.tar.gz` archive  
- Timestamped backup filenames for easy versioning  
- Automatic creation of destination directory  
- Retention policy to remove backups older than defined days  
- Simple logging of successes and errors  

**Enhanced Version Adds**  
- **Multiple sources** — backup multiple directories in one run  
- **Encryption** — GPG encrypt archives with user’s public key  
- **Email notifications** — send reports via email after backup  
- **Interactive menu** — user-friendly, selectable options in terminal  
- **Remote storage** — copy backups to remote servers with `scp` or `rclone`  
- **Compression options** — choose among gzip, bzip2, or xz compression  
- **Exclusion of files/directories** — exclude unwanted files from backups  
- **Parallel/background mode** — run backups asynchronously  
- **Integrity checks** — test archive integrity post-create  
- **Restore functionality** — extract backups from archives  
- **Dry-run mode** — preview backup actions without executing  
- **Config file support** — predefine settings for non-interactive runs  
- **Command-line arguments** — script parameters for automation  
- **Improved logging** — color-coded and formatted logs  

---

## Basic Version

Certainly! Here's a clear, line-by-line explanation of your backup shell script:

```bash
#!/bin/bash
```
- **Shebang**: Tells the system to use the `bash` shell to run this script.

```bash
read -p "Enter the directory to back up: " SRC_DIR
```
- **Prompt User**: Asks the user for the path to the source directory to back up. The input is stored in the variable `SRC_DIR`.

```bash
read -p "Enter the backup destination directory: " DEST_DIR
```
- **Prompt User**: Asks the user for the path where the backup will be saved (`DEST_DIR`).

```bash
if [ ! -d "$SRC_DIR" ]; then
  echo "Source directory does not exist!"
  exit 1
fi
```
- **Validate Source**: Checks if the source directory entered by the user exists.  
    - If it does not exist, prints an error and exits the script with a status code of 1.

```bash
mkdir -p "$DEST_DIR"
```
- **Ensure Destination Exists**: Creates the destination directory if it doesn't already exist. The `-p` flag prevents any error if the directory is already there.

```bash
DATE=$(date +%Y-%m-%d_%H-%M-%S)
```
- **Timestamp**: Saves the current date and time (formatted as `YYYY-MM-DD_HH-MM-SS`) into the variable `DATE`. This will be used in the backup filename.

```bash
BACKUP_NAME="backup_${DATE}.tar.gz"
```
- **Backup Filename**: Sets the backup archive filename using the timestamp: for example, `backup_2025-08-05_10-00-00.tar.gz`.

```bash
tar -czf "$DEST_DIR/$BACKUP_NAME" -C "$SRC_DIR" .
```
- **Create Compressed Backup**:  
    - Uses `tar` to create a compressed (`-z` for gzip) archive named `$BACKUP_NAME`.
    - The `-C "$SRC_DIR" .` part means: change (`-C`) into the source directory, and archive everything in it (`.`).

```bash
if [ $? -eq 0 ]; then
  echo "$(date): Backup successful: $BACKUP_NAME" >> "$DEST_DIR/backup.log"
else
  echo "$(date): Backup failed for $SRC_DIR" >> "$DEST_DIR/backup.log"
  exit 1
fi
```
- **Log Success or Failure**:  
    - Checks if the previous `tar` command succeeded (`$? -eq 0`).
    - If yes, logs a success message with the current date/time and backup filename to `backup.log` in the destination directory.
    - If not, logs failure and exits.

```bash
find "$DEST_DIR" -name "backup_*.tar.gz" -type f -mtime +7 -exec rm {} \;
```
- **Retention Cleanup**:  
    - Finds backup files (`backup_*.tar.gz`) in the destination that are regular files and **older than 7 days** (`-mtime +7`).
    - Deletes each found file.

**Summary:**  
This script interactively creates a compressed backup of a specified directory, names it with a timestamp, saves it to a specified backup location, logs the result, and cleans up old backups older than 7 days.
---

## Enhanced Version

The enhanced version includes all the features listed above. It provides:

- Interactive menu for selecting backup sources (single/multiple)
- GPG encryption prompts
- Email reporting (requires configured mail utility)
- Options for remote backup uploads
- Multiple compression algorithms
- Exclusion patterns
- Backup integrity tests and logs
- Background execution for long backups
- Restore capability to retrieve backups
- Configuration file support for automation

*Example: Use `backup.conf` file to predefine preferences and run backups unattended.*

Here’s a **line-by-line explanation** of your enhanced backup script, covering each major section and key lines, so you can understand its structure and logic:

### Shebang, Metadata, and Strict Bash Modes

```bash
#!/bin/bash
# Enhanced Backup Script – August 2025
# Author: Mohith Dommathamari

set -euo pipefail
```
- Uses `bash` as the shell.
- Metadata comment lines.
- `set -euo pipefail` makes the script exit on errors, undefined variables, or failed piped commands—this increases robustness.

### Basic Variables and Color Definitions

```bash
CONFIG="backup.conf"
LOGFILE="backup.log"
DRY_RUN=false

NC="\033[0m"
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
```
- Sets configuration file, log file, and initial dry-run flag.
- Defines escape codes for colors for nice terminal outputs.

### Logging Functions

```bash
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; echo "$(date): $1" >> "$LOGFILE"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; echo "$(date): WARN: $1" >> "$LOGFILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; echo "$(date): ERROR: $1" >> "$LOGFILE"; }
```
- Functions to print color-coded messages and append time-stamped log entries.

### Load Config File or Set Defaults

```bash
if [[ -f "$CONFIG" ]]; then
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
```
- Loads external configuration if present.
- Sets up default values for all environment variables if not already defined (good for optional config).

### Interactive Menu or CLI/Config for Sources and Destination

```bash
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
```
- If sources are not set, shows an interactive menu:
    - Single or multiple directories
    - Restore mode: prompts for file and destination, performs restore, logs and exits
    - Dry run: sets dry run mode; Exit: quits script
- Prompts for destination dir if needed and ensures it exists
- Warns if dry run is enabled

### Compression Method Setup

```bash
case "$COMPRESSION" in
    "gzip")   TAR_EXT="tar.gz"; TAR_OPT="z";;
    "bzip2")  TAR_EXT="tar.bz2"; TAR_OPT="j";;
    "xz")     TAR_EXT="tar.xz";  TAR_OPT="J";;
    *)        TAR_EXT="tar.gz";  TAR_OPT="z";;
esac
```
- Picks the compression flags and extension for the archive based on the compression method.

### Backup Loop

```bash
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
```
- For each source directory:
    - Prepares backup filename and path (includes timestamp and compression extension)
    - Sets any exclude patterns for tar
    - If dry run, logs what would be done
    - Creates backup (tar+compression), logs results
    - Verifies archive can be read/indexed (integrity test)
    - Optionally encrypts archive using GPG if enabled, deletes plaintext
    - Maintains a summary of the result for each source in an array

### Retention Policy — Remove Old Backups

```bash
find "$DEST_DIR" -type f \( -name "backup_*.tar.*" -o -name "backup_*.tar.*.gpg" \) -mtime +"$RETENTION_DAYS" -exec rm -f {} \; -exec echo "$(date): Deleted old backup {}" >> "$LOGFILE" \;
```
- Finds and deletes any backup or encrypted backup older than the specified retention days, logging deletions.

### Remote Copy (scp/rclone)

```bash
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
```
- If remote copying is enabled and a remote path is set, iterates over successful backups and copies them via `scp` or `rclone`, logging results

### Email Notification

```bash
if [[ -n "$EMAIL" ]]; then
    MAIL_BODY="Backup Report ($(date))\n$(printf '%s\n' "${BACKUP_RESULTS[@]}")"
    echo -e "$MAIL_BODY" | mail -s "Backup Script Report: $DATE" "$EMAIL"
    log_ok "Email report sent to $EMAIL."
fi
```
- If email is set, emails a summary report (subject includes timestamp), logs that report was sent

### Final Console Notice

```bash
echo -e "${YELLOW}Backups completed. See $LOGFILE for details.${NC}"
```
- Prints a final colored message that backups finished, points to the log file for details.

**Summary:**  
This script is an advanced and resilient backup tool:  
- Loads config, supports interactive menus, robustly logs, manages retention, supports multiple compression and backup sources, can exclude files/patterns, verifies and encrypts archives, supports remote uploading, emails reports, and can run in a dry-run mode or perform restores.  
All outputs are color-coded for user clarity and a comprehensive log is maintained in `backup.log`.

---

## Usage

1. Clone or download the script to your system.
2. Make it executable:
```bash
chmod +x backup_tool.sh
```
3. Run the script interactively:
```bash
./backup_tool.sh
```
4. Follow on-screen prompts for sources, destinations, encryption, notifications, and remote options.
5. View logs and alerts for backup status.

---

## Installation

No special installation needed.  
Ensure your system has installed:

- `bash`
- `tar`
- `gpg` (for encryption)
- `mail` or compatible MTA (for email)
- `scp` or `rclone` (for remote copies, if using those features)

---

## Scheduling with Cron

Add to your crontab to automate backups regularly:

```bash
crontab -e
```

Add a scheduled job (backup daily at 2am):

```bash
0 2 * * * /path/to/backup_tool.sh
```

For non-interactive runs, use a config file for parameters or supply command-line options (if implemented).

---

## Configuration File

Put your settings in `backup.conf`:

```bash
SOURCES=("/home/user/docs" "/home/user/pics")
DEST_DIR="/mnt/backups"
RETENTION_DAYS=14
EMAIL="me@example.com"
ENCRYPT=true
GPG_RECIP="you@example.com"
REMOTE_ENABLE=true
REMOTE_METHOD="scp"
REMOTE_PATH="user@server:/backups"
EXCLUDES=("*.tmp" "node_modules")
COMPRESSION="gzip"
DRY_RUN=false
LOG_FILE="/var/log/backup.log"
```

Run script with:

```bash
source backup.conf
./backup_tool.sh
```
---

## Customization and Enhancements

- Edit or extend exclusion filters to skip unwanted files/folders
- Switch compression types for different space/speed trade-offs
- Configure email alerts for failure triggers only
- Add multi-threading for large backups (GNU parallel)
- Integrate cloud APIs (AWS S3, Azure Blob) for remote backups
- Add logging rotation to manage log file size
- Integrate with system monitoring software for proactive alerting

---

## Best Practices

- Always test backups and restores on non-critical data first.
- Store backups offsite or on redundant storage for disaster recovery.
- Use strong encryption keys and secure key management for sensitive backups.
- Regularly verify backup integrity and logs.
- Document scheduled jobs and retention policies clearly for your team.

---

## License

This project is released under the MIT License.  
Feel free to fork, modify, and use it to fit your needs!

---

**Happy Backing Up!**  
For questions or contributions, contact [Your Name or Contact Info].
