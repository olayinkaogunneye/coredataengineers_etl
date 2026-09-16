# CoreDataEngineers Bash ETL Pipeline

A Bash-based ETL pipeline built as part of the CoreDataEngineers data engineering bootcamp.

The project demonstrates how to extract data from a public CSV source, validate the extracted structure, transform the required fields, validate the transformed output, load the result into a Gold layer, and automate execution using cron.

## Project Overview

The pipeline processes the New Zealand Stats Annual Enterprise Survey 2023 financial-year provisional dataset.

The workflow is:

**Extract → Validate → Transform → Validate → Load**

The project also includes a separate Bash script for moving CSV and JSON files from a user-specified source directory into a common destination directory.

## ETL Pipeline

### 1. Extract

The ETL script downloads the source CSV using `curl`.

The source URL is supplied through the `CSV_URL` environment variable rather than being hard-coded into the script.

```bash
export CSV_URL="https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"
```

The downloaded file is stored in:

```text
raw/
```

The download uses:

* `-L` to follow redirects
* `-f` to fail when the HTTP request returns an error

### 2. Validate the raw data

After extraction, the script reads the CSV header and compares it against the expected source structure.

This provides a basic structural check before transformation begins.

The validation also handles the carriage-return character that can appear in Windows-style CSV line endings.

### 3. Transform

`awk` is used to:

* parse the CSV fields
* select the required columns
* rename `Variable_code` to `variable_code`
* create the required output structure

The transformed dataset contains:

```text
year,Value,Units,variable_code
```

The transformed file is written to:

```text
Transformed/2023_year_finance.csv
```

### 4. Validate the transformed data

The script checks that:

* the transformed file exists and is not empty
* the transformed header matches the required structure

The Gold layer is only updated after these checks succeed.

### 5. Load

The validated transformed file is copied into:

```text
Gold/2023_year_finance.csv
```

The Gold output is then checked to confirm that it exists and is not empty.

## File Organisation

```text
coredataengineers_etl_mastery/
│
├── raw/
│   └── annual-enterprise-survey-2023-financial-year-provisional.csv
│
├── Transformed/
│   └── 2023_year_finance.csv
│
├── Gold/
│   └── 2023_year_finance.csv
│
├── json_and_CSV/
│   ├── customers.json
│   └── sales.csv
│
├── my_files/
│   └── notes.txt
│
├── scripts/
│   ├── etl.sh
│   └── move_files.sh
│
├── .gitignore
└── README.md
```

## Scripts

### `scripts/etl.sh`

Runs the complete ETL workflow:

```text
CSV_URL
   ↓
Extract
   ↓
Raw validation
   ↓
Transform with awk
   ↓
Transformed validation
   ↓
Load
   ↓
Gold
```

The script uses paths derived from its own location, allowing it to be run without relying on the current working directory.

### `scripts/move_files.sh`

Moves CSV and JSON files from a source directory supplied as the first command-line argument.

Example:

```bash
bash scripts/move_files.sh my_files
```

The script:

1. receives the source directory through `$1`
2. checks that the directory exists
3. identifies CSV and JSON files using `find`
4. moves matching files into `json_and_CSV/`

Non-CSV/JSON files are left untouched.

## Automation with Cron

The ETL pipeline can be scheduled using cron.

Example:

```text
0 1 * * * . "$HOME/.etl_env" && /bin/bash "/home/olayi/cde_assignments/coredataengineers_etl_mastery/scripts/etl.sh" >> "/home/olayi/cde_assignments/coredataengineers_etl_mastery/etl.log" 2>&1
```

The schedule:

```text
0 1 * * *
```

means the ETL runs every day at 1:00 AM.

The environment file provides the `CSV_URL` variable required by the ETL script.

Output and errors are redirected to `etl.log` for monitoring.

## Running the ETL Manually

Load the environment variable:

```bash
. "$HOME/.etl_env"
```

Then run:

```bash
bash scripts/etl.sh
```

Or in one command:

```bash
. "$HOME/.etl_env" && bash scripts/etl.sh
```

## Error Handling

The pipeline uses Bash exit statuses to stop processing when important steps fail.

Examples include:

* missing `CSV_URL`
* failed HTTP download
* unexpected source header
* failed transformation
* unexpected transformed header
* empty output files

A failed validation prevents the pipeline from continuing to the next stage.

For example, the Gold layer is only loaded after the transformed output has passed validation.

## Validation Strategy

The pipeline deliberately validates structure rather than relying on a fixed number of rows.

This is because the source dataset may legitimately change in size over time.

Current checks include:

| Stage          | Check                                   |
| -------------- | --------------------------------------- |
| Extraction     | `curl -f` confirms HTTP request success |
| Raw            | Expected source header                  |
| Transformation | Output file is non-empty                |
| Transformation | Required transformed header             |
| Load           | Gold file is non-empty                  |

## Testing

The pipeline was tested for:

* successful data extraction
* failed HTTP requests
* source-header validation
* transformed-header validation
* successful Gold loading
* missing source directories
* non-existent source directories
* CSV/JSON file selection
* leaving unrelated file types untouched
* repeated execution
* cron-style execution and logging

The ETL successfully produced a transformed dataset containing the required fields and loaded it into the Gold layer.

## Technologies

* Bash
* Linux / WSL
* `curl`
* `awk`
* `find`
* `cron`
* Git
* GitHub

## Current Limitations

This project intentionally keeps the implementation within the scope of the bootcamp assignment.

Potential production improvements could include:

* atomic or staged loading into the Gold layer
* output versioning or timestamps
* stronger data-quality validation
* structured logging
* alerting and monitoring
* dependency/orchestration management
* more robust CSV parsing for complex CSV edge cases

A fixed row-count validation was deliberately not implemented because the source dataset can legitimately change in size.

## Key Learning

This project strengthened practical understanding of Bash-based ETL concepts including:

* environment variables
* command-line arguments
* shell variables and quoting
* exit codes
* conditional execution
* command substitution
* pipes and redirection
* CSV field extraction with `awk`
* file and directory validation
* cron scheduling
* logging
* Git workflow

The main lesson was that an ETL pipeline is not simply about moving data from one location to another. Each stage should provide enough validation and failure handling to prevent an invalid result from silently moving further through the pipeline.