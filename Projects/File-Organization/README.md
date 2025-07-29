# Project 1: File Organization Script (Shell Scripting)

The goal of this project is to automate the sorting and organization of files within a directory. This is a classic beginner shell scripting project that will build your practical skills in file handling, loops, and conditional statements.

## Project Overview

**Objective:**  
Automatically sort files from a specified directory into folders based on criteria like file extension, date, or type.

**Key Concepts:**
- Shell commands (`mv`, `mkdir`, `ls`, etc.)
- Loops and conditional statements
- String manipulation and file parameter expansion
- User input and file operations

## Step-by-Step Guide

### 1. Project Requirements

- Linux environment (Ubuntu/WSL is fine)
- Basic knowledge of terminal commands
- Editor (VS Code, nano, vim, etc.)

### 2. Sample Use Cases

- Organize all `.jpg` images into an “Images” folder.
- Sort documents (`.pdf`, `.docx`) into a “Documents” folder.
- Place videos (`.mp4`, `.mov`) into a “Videos” folder.

### 3. Script Outline

#### a. User Input
Prompt the user for:
- Source directory (where files are unsorted)
- Organization method (by extension/type)

#### b. Loop Through Files
- For each file in the directory, determine its type/extension.
- If the target folder does not exist, create it.
- Move the file into the corresponding folder.

#### c. Error Handling
- Skip directories/subfolders.
- Optionally, skip or handle duplicate files gracefully.

### 4. Example Script

Below is a sample shell script (Bash) that organizes files by extension:

```bash
#!/bin/bash

read -p "Enter the directory to organize: " DIR

cd "$DIR" || { echo "Directory not found!"; exit 1; }

for FILE in *; do
    # Skip folders
    [ -d "$FILE" ] && continue

    # Extract file extension
    EXT="${FILE##*.}"
    # Handle files without extension
    [ "$EXT" == "$FILE" ] && EXT="no_extension"

    # Create folder if not exists
    mkdir -p "$EXT"

    mv "$FILE" "$EXT/"
done

echo "Files organized by extension!"
```

#### Script Breakdown
- Prompts for the directory.
- Ignores subdirectories.
- For each file, extracts its extension (or labels “no_extension”).
- Makes a folder for each extension if needed.
- Moves files into the appropriate folder.

### 5. How to Run

1. Save the script as `organize_files.sh`.
2. Make it executable:  
   ```bash
   chmod +x organize_files.sh
   ```
3. Run:
   ```bash
   ./organize_files.sh
   ```

### 6. Extensions & Next Steps

- Organize files by date modified or creation date.
- Add support for recursive directory organization.
- Build an interactive menu for custom organization rules.
- Log actions to a text file for audit.

## Best Practices

- Always test scripts on sample directories to prevent accidental data loss.
- Add comments and handle edge cases (special characters, spaces in filenames).
- Use `set -e` for better error handling in production scripts.

Completing this project will help you gain real, hands-on experience with shell scripting essentials and build a foundation for more advanced automation projects. 