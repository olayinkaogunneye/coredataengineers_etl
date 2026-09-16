#!/bin/bash

# ============================
# 📌 STAGE 0 — Setup & Paths
# ============================

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

RAW_DIR="$PROJECT_DIR/raw"
TRANSFORMED_DIR="$PROJECT_DIR/Transformed"
GOLD_DIR="$PROJECT_DIR/Gold"

# Expected header for validation
EXPECTED_HEADER="Year,Industry_aggregation_NZSIOC,Industry_code_NZSIOC,Industry_name_NZSIOC,Units,Variable_code,
Variable_name,Variable_category,Value,Industry_code_ANZSIC06"

echo "Project: $PROJECT_DIR"
echo "Raw: $RAW_DIR"
echo "Transformed: $TRANSFORMED_DIR"
echo "Gold: $GOLD_DIR"

# CSV URL must be provided as environment variable
CSV_URL="${CSV_URL:? CSV_URL environment variable not found}"

# Create directories for each ETL stage
mkdir -p "$RAW_DIR" "$TRANSFORMED_DIR" "$GOLD_DIR"

# ============================
# 📌 STAGE 1 — Extract (Download)
# ============================

if curl -f -L "$CSV_URL" -o "$RAW_DIR/annual-enterprise-survey-2023-financial-year-provisional.csv"
then
        echo 'download successful'
else
        echo 'download failed'
        exit 1
fi

# ============================
# 📌 STAGE 2 — Validate Raw File
# ============================

ACTUAL_HEADER="$(head -n 1 "$RAW_DIR/annual-enterprise-survey-2023-financial-year-provisional.csv")"

# Remove carriage return if present
ACTUAL_HEADER_CLEAN="$(printf '%s' "$ACTUAL_HEADER" | tr -d '\r')"

# Compare expected vs actual header
if [ "$EXPECTED_HEADER" = "$ACTUAL_HEADER_CLEAN" ]; then
        echo "Match,validation successful"
else
        echo "No Match, validation failed"
        exit 1
fi

# ============================
# 📌 STAGE 3 — Transform
# ============================

# Extract selected columns using awk
awk 'BEGIN {FPAT = "([^,]+)|(\"[^\"]+\")"}
NR==1 {print "year,Value,Units,variable_code"}
NR>1 {print $1 "," $9 "," $5 "," $6}' \
"$RAW_DIR/annual-enterprise-survey-2023-financial-year-provisional.csv" \
    > "$TRANSFORMED_DIR/2023_year_finance.csv"

# Check if transformed file is non‑empty
if [ -s "$TRANSFORMED_DIR/2023_year_finance.csv" ]; then
    echo "Transformation successful"
else
    echo "Transformation failed"
    exit 1
fi

# ============================
# 📌 STAGE 4 — Validate Transformed File
# ============================

EXPECTED_TRANSFORMED_HEADER="year,Value,Units,variable_code"

ACTUAL_TRANSFORMED_HEADER="$(head -n 1 "$TRANSFORMED_DIR/2023_year_finance.csv")"

if [ "$EXPECTED_TRANSFORMED_HEADER" = "$ACTUAL_TRANSFORMED_HEADER" ]; then
    echo "Transformed header validation successful"
else
    echo "Transformed header validation failed"
    exit 1
fi

# ============================
# 📌 STAGE 5 — Load (Copy to Gold Layer)
# ============================

cp "$TRANSFORMED_DIR/2023_year_finance.csv" "$GOLD_DIR/2023_year_finance.csv"

if [ -f "$GOLD_DIR/2023_year_finance.csv" ]; then
    echo "Load successful"
else
    echo "Load failed"
    exit 1
fi