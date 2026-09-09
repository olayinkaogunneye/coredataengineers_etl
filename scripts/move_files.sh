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
