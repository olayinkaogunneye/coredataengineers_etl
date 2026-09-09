# CoreDataEngineers Linux and Git ETL Project

## Project Overview

This project demonstrates a simple ETL workflow using Bash scripting, Linux commands, cron scheduling, and Git version control.

The project uses the New Zealand Annual Enterprise Survey 2023 financial-year provisional dataset.

## Project Structure

```text
coredataengineers_etl/
├── Gold/
├── Transformed/
├── json_and_CSV/
├── raw/
├── scripts/
│   ├── etl.sh
│   └── move_files.sh
├── .gitignore
└── README.md


## Project Structure

The project is organised into separate directories for the raw data, transformed data, final output, scripts, and CSV/JSON file management.

- `raw/` — stores the original CSV downloaded from the source.
- `Transformed/` — stores the transformed dataset.
- `Gold/` — stores the final output of the ETL process.
- `json_and_CSV/` — destination for CSV and JSON files moved by the file-management script.
- `scripts/` — contains the Bash scripts used in the project.
  - `etl.sh` — performs the Extract, Transform, and Load process.
  - `move_files.sh` — moves CSV and JSON files from a specified directory.
- `.gitignore` — specifies files that should not be tracked by Git.
- `README.md` — provides documentation for the project.


## ETL Pipeline

The ETL process is implemented in `scripts/etl.sh`.

### Extract

The script downloads the Annual Enterprise Survey 2023 financial-year provisional CSV dataset using the `CSV_URL` environment variable.

The downloaded file is saved in the `raw/` directory.

### Transform

The transformation step uses `awk` to process the CSV file.

It:
- Renames `Variable_code` to `variable_code`
- Selects only the required columns: `year`, `Value`, `Units`, and `variable_code`
- Saves the transformed dataset as `Transformed/2023_year_finance.csv`

### Load

The transformed dataset is copied from the `Transformed/` directory into the `Gold/` directory.

The script displays a confirmation message after each stage to indicate whether the operation was successful.


### Running the ETL Script

The `CSV_URL` environment variable must be available before running the script.

The environment variable can be loaded and the ETL script executed with:

```bash
source ~/.etl_env
./scripts/etl.sh


## Cron Scheduling

The ETL script is scheduled to run automatically every day at midnight using cron.

The cron schedule is:

0 0 * * *

The cron job loads the CSV_URL environment variable, runs the ETL script, and records the script output in etl.log.

The cron job was tested by temporarily setting the schedule to run at a specific time and checking the log file to confirm that the ETL process executed successfully.


## CSV and JSON File Management

The `scripts/move_files.sh` script is used to move CSV and JSON files from a specified source directory into the `json_and_CSV/` directory.

The script accepts the source directory as an argument.

Example:

```bash
./scripts/move_files.sh <source_directory>



That last sentence is useful because it shows **you actually tested the requirement**, rather than merely creating the script.

Once that's in, we'll do the **Git Version Control** section.


## Git Version Control

Git is used to track changes throughout the project.

The project uses the `main` branch and includes the Bash scripts, ETL output files, documentation, and project configuration.


## Tools Used

- Bash
- Linux/Ubuntu (WSL)
- curl
- awk
- find
- mv
- cron
- Git
- GitHub
