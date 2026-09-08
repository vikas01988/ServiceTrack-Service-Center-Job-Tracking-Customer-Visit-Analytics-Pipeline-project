#  ServiceTrack — Service Center Job Tracking & Customer Visit Analytics Pipeline

A simple data engineering project for transforming service-center job data into clean Delta tables, business metrics, and SQL analytics.

## 1. 🏷️ Project Summary

- ServiceTrack uses a Medallion Architecture
- Built with PySpark, Delta Lake, SQL, and Databricks
- Focus: service jobs, technician performance, delays, repeat customers, and device trends

 > **Note:** The original project specification referred to JSON files. However, this implementation uses **CSV files** throughout the pipeline as instructed by my mentor.

## 2. 🔄 Project Workflow

```text
CSV Files → Bronze Layer → Silver Layer → Gold Layer → SQL Analytics
   ↓            ↓             ↓             ↓             ↓
customers.csv  Clean & store  Enrich & validate  Create metrics  Query insights
devices.csv    raw Delta      business logic    Gold tables      charts/reports
service_jobs.csv
```

## 3. 📁 Project Structure

```text
celebal project/
├── datasets/
│   ├── customers.csv
│   ├── devices.csv
│   └── service_jobs.csv
├── notebooks/
│   ├── 00_Config_Utils.ipynb
│   ├── 02_Bronze_Layer.ipynb
│   ├── 03_Silver_Layer.ipynb
│   ├── 04_Gold_Layer.ipynb
│   └── 06_End_to_End_Pipeline.ipynb
├── sql analysis/
│   └── 05_SQL_Analytics.sql
├── screenshots/
├── Data_Dictionary.md
├── README.md
└── requirements.txt
```

## 4. 🏗️ Core Architecture

- Bronze → raw ingestion into Delta tables
- Silver → cleaning, deduplication, null handling, date conversion
- Gold → business-ready metrics and analytics tables
- Shared config in `00_Config_Utils.ipynb`

## 5. ⚙️ Key Features

- Reusable functions: `load_csv()`, `save_as_delta()`, `convert_dates()`, `validate_row_count()`
- Parameterized file paths using Databricks widgets
- Logging with `logging` module
- Error handling with `try/except`
- Duplicate and null checks
- Negative cost validation
- `job_status_flag` created in Silver layer
- Row count and null validation in the end-to-end pipeline

## 6. 📊 Gold Layer Outputs

- Technician performance table
- Delay analysis table
- Repeat customer tables
- Device brand analysis table
- Latest customer visit table
- SQL analytics with CASE, CTE, GROUP BY, HAVING, and window functions

## 7. ✅ Data Quality Checks

- Duplicate removal: 1510 → 1500 rows
- Missing technician names handled
- Missing repair notes filled
- Date values verified before conversion
- Negative costs prevented

## 8. 🧰 Tech Stack

- Python
- PySpark
- Delta Lake
- SQL
- Databricks

## 9. ▶️ How to Run

1. Upload the CSV files from `datasets/` to a Databricks volume
2. Open `notebooks/06_End_to_End_Pipeline.ipynb`
3. Run the notebook
4. Open `sql analysis/05_SQL_Analytics.sql` for analytics queries

## 10. 📚 Documentation

- Data dictionary available in `Data_Dictionary.md`
- Screenshots stored in `screenshots/`

## 11. ✍️ Author

- VIKAS SHARMA

