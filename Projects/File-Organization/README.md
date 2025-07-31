# 🗃️ File Organizer Bash Scripts

This repository includes two robust Bash scripts designed to organize files in Linux directories:

- **1. Basic File Organizer:**  
  Organizes files in a specified directory into subfolders based on their file extensions.
- **2. Enhanced Modular File Organizer:**  
  Offers a menu to organize files recursively (including sub-directories) by file extension, last modified date, or creation date. Includes full audit logging and robust error handling.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Usage Instructions](#usage-instructions)
- [Basic File Organizer: Code Explanation](#basic-file-organizer-code-explanation)
- [Enhanced File Organizer: Explanation & Features](#enhanced-file-organizer-explanation--features)
    - [Interactive Organization Menu](#interactive-organization-menu)
    - [Recursive Handling](#recursive-handling)
    - [Audit Logging](#audit-logging)
    - [Error Handling](#error-handling)
- [Sample Test Case](#sample-test-case)
- [Extending the Script](#extending-the-script)
- [License](#license)

## Overview

**Automating file organization** is a recurring task for system admins and DevOps professionals. These scripts help you:
- Quickly sort files for cleanup.
- Practice practical Bash scripting logic.
- Build robust automation skills applicable for career growth.

## Features

### Basic File Organizer
- Organizes all files in a user-specified directory based on their file extension.
- Files with no extension are grouped in a `no_extension` folder.
- Ignores subdirectories.
- Simple, minimal, and safe (does not overwrite existing files).

### Enhanced Modular File Organizer
- Recursively finds files in the target directory and all subdirectories.
- Lets the user choose organization method:
  - **By extension**
  - **By date modified** (YYYY-MM)
  - **By date created** (if supported, fallback to modified)
- Interactive menu selection.
- Generates a detailed audit log of every file moved.
- Robust error and edge-case handling.

## Usage Instructions

### 1. Clone or Download

```bash
git clone https://github.com/your-username/file-organizer-scripts.git
cd file-organizer-scripts
```

### 2. Prepare a Test Directory

Create a folder with various files and subfolders for testing, or use your own.

```bash
mkdir testdir
cd testdir
touch file1.txt file2.jpg file3 .bashrc script.sh notes
mkdir subdir
touch subdir/file4.doc subdir/file5.txt
```

### 3. Make the Script Executable

```bash
chmod +x organize_files.sh           # For basic
chmod +x enhanced_organize.sh        # For enhanced
```

### 4. Run the Script

#### **Basic File Organizer**

```bash
../organize_files.sh      # (run from inside the folder you want to organize)
```

#### **Enhanced Modular File Organizer**

```bash
../enhanced_organize.sh  # (can be run from anywhere)
```

- Enter the **full path** of your target directory when prompted.
- Follow the on-screen menu to select organization method.

## Basic File Organizer: Code Explanation

```bash
#!/bin/bash
```
- Shebang: Tells the system to use the Bash shell to interpret this script.

```bash
read -p "Enter the directory to organize: " DIR
```
- Prompt for Directory: Asks the user to input the path to the directory they want to organize and stores the answer in the variable DIR.

```bash
cd "$DIR" || { echo "Directory not found!"; exit 1; }
```
- Change Directory: Attempts to move into the specified directory.
- If that fails (e.g., the directory does not exist), prints "Directory not found!" and stops the script.

```bash
for FILE in *; do
```
- Iterate Files: Initiates a loop over each item in the directory. The * matches all files and folders in the current directory.

```bash
    [ -d "$FILE" ] && continue                     # Skip folders
```
- Skip Folders: Checks if ITEM is a directory with [ -d "$FILE" ]. If so, skips it (does not process folders).

```bash
    EXT="${FILE##*.}"                              # Get extension (after last dot)
```
- Extract Extension: Gets the file extension by stripping off everything before the last dot (.) in the filename.
- Example: For image.png, EXT becomes png.

```bash
    [ "$EXT" == "$FILE" ] && EXT="no_extension"    # Handle files with no extension
```
- Handle No Extension: If the extracted extension is identical to the filename (meaning there's no dot), assigns "no_extension" as the extension's value.

```bash
    mkdir -p "$EXT"                                # Create folder for this extension if not exists
```
- Make Directory: Creates a folder named after the extension if it doesn't already exist. The -p option avoids errors if the folder already exists.

```bash
    mv "$FILE" "$EXT/"                             # Move file into its folder
```
- Move File: Moves the file into the directory corresponding to its extension.

```bash
done
```
- End Loop: Closes the for loop.

```bash
echo "Files organized by extension!"
```
- Script Completion Message: Informs the user that the operation has finished.

**How it works:**
- Asks you for a directory.
- For each file (not folders), extracts the extension (e.g. txt, jpg).
- If file has no extension, it's put in the `no_extension/` folder.
- Each file is moved into the right folder.
- Effective for simple, shallow directories.


## Enhanced File Organizer: Explanation & Features

```bash
#!/bin/bash
LOGFILE="organizer_audit.log"
```
- Declares the shell and gives the script a comment header.
- Sets the log file to track file moves: organizer_audit.log.

### Function: prompt_directory
```bash
prompt_directory() {
  read -p "Enter the directory to organize: " DIR
  if [ ! -d "$DIR" ]; then
    echo "Directory not found!"
    exit 1
  fi
}
```
- Prompts the user for a directory.
- Checks for existence (-d "$DIR"), exits if not present.

### Function: choose_method
```bash
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
```
- Presents options for organization method (extension, date modified, date created, exit).
- Sets the variable ORGANIZE_TYPE accordingly, or exits if chosen.
- Uses Bash’s select for a numbered menu.

### Function: get_target_dir
```bash
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
```
- Determines the target folder based on the chosen organization type:
- By extension: gets extension, handles files with no extension.
- By modified date: gets last modified (stat -c %y) year-month.
- By created date: gets creation (stat -c %w), falls back to modified if missing.
- Handles missing values (e.g., for filesystems with no birthdate) by using "unknown_date".
- Uses the parent directory with the calculated subfolder.

### Function: log_action
```bash
log_action() {
  ACTION="$1"
  echo "$ACTION at $(date)" >> "$LOGFILE"
}
```
- Logs each move action with a timestamp to the audit log.

### Function: organize_files
```bash
organize_files() {
  find "$DIR" -type f | while read -r FILE; do
    TARGET_DIR="$(get_target_dir "$FILE")"
    mkdir -p "$TARGET_DIR"
    BASENAME="$(basename "$FILE")"
    mv -n "$FILE" "$TARGET_DIR/"
    log_action "Moved $FILE -> $TARGET_DIR/$BASENAME"
  done
}
```
- Uses find to list all files recursively inside the chosen directory.
- For each file:
  - Determines the appropriate target directory.
  - Creates it if needed with mkdir -p.
  - Gets just the file’s basename.
  - Moves the file (-n = don’t overwrite existing).
  - Logs the move.

Main Script Block
bash
# ========== Main Script ==========
prompt_directory
choose_method
organize_files

echo "Files organized by $([ "$ORGANIZE_TYPE" = "ext" ] && echo 'extension' || echo 'date')!"
echo "Audit log: $LOGFILE"
Runs the three major steps: gets directory, gets chosen method, organizes files.

Prints a summary and location of the log.

### Interactive Organization Menu

- When you start the script, select organization method:
    - **By Extension:** (`.txt`, `.jpg`, etc.)
    - **By Date Modified:** (folders like `2025-07`)
    - **By Date Created:** (uses `stat -c %w`, falls back if unsupported)

### Recursive Handling

- All files are discovered recursively (in subfolders).
- Each is relocated into folders within its original directory path.

### Audit Logging

- Every file move is appended to `organizer_audit.log`.
- Includes old location, new folder, filename, and timestamp.

### Error Handling

- Exits with a clear message if directory is not found.
- Handles missing extensions, filesystems without creation date, and naming collisions (`mv -n` — will not overwrite).


---

## Sample Test Case

Suppose your directory tree is:

```
testdir/
  report.pdf
  image1.jpg
  .gitignore
  README
  subfolder/
    data.csv
    image2.jpg
```

**Organize by Extension:**
- `pdf/`, `jpg/`, `csv/`, `no_extension/` subfolders created where files are placed accordingly.

**Organize by Modified Date:**
- Files moved into e.g. `2024-07/` if those were their last modified years and months.

## Extending the Script

Some suggested enhancements:
- **"Dry run" mode:** Print changes without moving anything.
- **Filename collision handling:** Append timestamp or a number if duplicate exists.
- **Undo/restore:** Optionally, keep a backup or reverse moves listed in the log.
- **Custom rules:** Offer menu for size, owner, or other file attributes.
- **Integration:** Schedule as a cron job for routine cleanup.

## License

This repository is for learning and professional development purposes.  
Feel free to fork, modify, and share with attribution!

**Questions? Want a new feature or more in-depth scripting help?**  
Open an issue or start a discussion!

**Happy Automating!**
