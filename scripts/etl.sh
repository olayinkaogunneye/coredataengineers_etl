#!/bin/bash

# ==========================================
# CoreDataEngineers - Annual Enterprise Survey ETL
# ==========================================

echo "=========================================="
echo "Starting ETL process..."
echo "=========================================="

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RAW_DIR="$PROJECT_DIR/raw"
TRANSFORMED_DIR="$PROJECT_DIR/Transformed"
GOLD_DIR="$PROJECT_DIR/Gold"

CSV_URL="${CSV_URL:?CSV_URL environment variable is not set}"

mkdir -p "$RAW_DIR" "$TRANSFORMED_DIR" "$GOLD_DIR"

echo "Starting extraction..."

curl -L "$CSV_URL" -o "$RAW_DIR/annual-enterprise-survey-2023-financial-year-provisional.csv"

if [ -f "$RAW_DIR/annual-enterprise-survey-2023-financial-year-provisional.csv" ]; then
    echo "Extraction successful: file saved in $RAW_DIR"
else
    echo "Extraction failed."
    exit 1
fi

echo "Starting transformation..."

awk 'BEGIN { FPAT = "([^,]+)|(\"[^\"]+\")" }
NR==1 { print "year,Value,Units,variable_code" }
NR>1 { print $1 "," $9 "," $5 "," $6 }' \
"$RAW_DIR/annual-enterprise-survey-2023-financial-year-provisional.csv" \
> "$TRANSFORMED_DIR/2023_year_finance.csv"

if [ -f "$TRANSFORMED_DIR/2023_year_finance.csv" ]; then
    echo "Transformation successful: file saved in $TRANSFORMED_DIR"
else
    echo "Transformation failed."
    exit 1
fi

echo "Starting load..."

cp "$TRANSFORMED_DIR/2023_year_finance.csv" "$GOLD_DIR/2023_year_finance.csv"

if [ -f "$GOLD_DIR/2023_year_finance.csv" ]; then
    echo "Load successful: file saved in $GOLD_DIR"
else
    echo "Load failed."
    exit 1
fi