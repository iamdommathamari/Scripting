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

```bash
#!/bin/bash

read -p "Enter the directory to back up: " SRC_DIR
read -p "Enter the backup destination directory: " DEST_DIR

if [ ! -d "$SRC_DIR" ]; then
  echo "Source directory does not exist!"
  exit 1
fi

mkdir -p "$DEST_DIR"

DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_NAME="backup_${DATE}.tar.gz"

tar -czf "$DEST_DIR/$BACKUP_NAME" -C "$SRC_DIR" .
if [ $? -eq 0 ]; then
  echo "$(date): Backup successful: $BACKUP_NAME" >> "$DEST_DIR/backup.log"
else
  echo "$(date): Backup failed for $SRC_DIR" >> "$DEST_DIR/backup.log"
  exit 1
fi

find "$DEST_DIR" -name "backup_*.tar.gz" -type f -mtime +7 -exec rm {} \;

```


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
