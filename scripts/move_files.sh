#!/bin/bash

SOURCE_DIR="$1"


if [ -z "$SOURCE_DIR" ]; then
    echo "Please provide a source directory."
    exit 1
fi


if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory does not exist: $SOURCE_DIR"
    exit 1
fi


PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEST_DIR="$PROJECT_DIR/json_and_CSV"

mkdir -p json_and_CSV


find "$SOURCE_DIR" -maxdepth 1 -type f \( -iname "*.csv" -o -iname "*.json" \) -exec mv {} "$DEST_DIR"/ \;

echo "CSV and JSON files have been moved to $DEST_DIR"



#!/bin/bash

# ============================
# 📌 STAGE 0 — Input Validation
# ============================

# Read source directory from first argument
SOURCE_DIR="$1"

# Ensure a directory was provided
if [ -z "$SOURCE_DIR" ]; then
    echo "Please provide a source directory."
    exit 1
fi

# Ensure the directory actually exists
if [ ! -d "$SOURCE_DIR" ]; then
        echo "Source directory does exit: $SOURCE_DIR"
        exit 1
fi

# ============================
# 📌 STAGE 1 — Setup Project Paths
# ============================

# Determine project root (one level above script location)
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Destination directory for extracted CSV + JSON files
DEST_DIR="$PROJECT_DIR/json_and_CSV"

# Create destination directory if missing
mkdir -p "$DEST_DIR"

# ============================
# 📌 STAGE 2 — Extract & Load
# ============================

# Find all CSV and JSON files in source directory and move them to DEST_DIR
find "$SOURCE_DIR" -type f \( -name "*.csv" -o -name "*.json" \) -exec mv {} "$DEST_DIR"/ \;