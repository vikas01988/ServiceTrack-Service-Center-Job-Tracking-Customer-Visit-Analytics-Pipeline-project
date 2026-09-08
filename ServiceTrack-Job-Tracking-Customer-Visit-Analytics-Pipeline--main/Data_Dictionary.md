# Data Dictionary — ServiceTrack Project

This document lists every column across the three source tables (`customers`, `devices`, `service_jobs`), what it means, and where it's used in the pipeline. Use this as a quick reference when reading the notebooks or writing new queries.

---

## 1. customers.csv → `bronze_customers` → `silver_enriched_jobs`

| Column Name | Data Type | Nullable | Description |
|---|---|---|---|
| `customer_id` | VARCHAR | No | Primary key. Unique identifier in format `CUST0001`–`CUST0300`. |
| `customer_name` | VARCHAR | No | Full name of the customer (first + last). |
| `phone_number` | VARCHAR | No | 10-digit mobile number. Unique per customer. |
| `email` | VARCHAR | No | Customer email address. Unique per customer. |
| `city` | VARCHAR | No | City of residence (14 Indian cities represented). |
| `registration_date` | DATE | No | Date the customer first registered with the service center. |

---

## 2. devices.csv → `bronze_devices` → `silver_enriched_jobs`

| Column Name | Data Type | Nullable | Description |
|---|---|---|---|
| `device_id` | VARCHAR | No | Primary key. Format `DEV001`–`DEV043`. |
| `brand` | VARCHAR | No | Device manufacturer (e.g. Samsung, Apple, Dell, Xiaomi). |
| `device_type` | VARCHAR | No | Category of device (e.g. Smartphone, Laptop, Air Conditioner). |
| `model_series` | VARCHAR | No | Brand + device type short label (e.g. Samsung SMA-Series). |
| `warranty_months` | INTEGER | No | Standard warranty duration in months: 6, 12, 18, or 24. |
| `price_range` | VARCHAR | No | Approximate price tier: Budget / Mid-range / Premium. |

---

## 3. service_jobs.csv → `bronze_service_jobs` → `silver_enriched_jobs`

| Column Name | Data Type | Nullable | Description |
|---|---|---|---|
| `job_id` | VARCHAR | No | Primary key. Format `JOB00001`. 10 duplicate rows existed in raw data — removed in Silver layer. |
| `customer_id` | VARCHAR | No | Foreign key → `customers.customer_id`. |
| `device_id` | VARCHAR | No | Foreign key → `devices.device_id`. |
| `issue_type` | VARCHAR | No | Type of fault reported (e.g. Screen Damage, Battery Issue, Overheating). |
| `job_status` | VARCHAR | No | Current status: `Completed` \| `In Progress` \| `Pending` \| `Cancelled`. |
| `received_date` | DATE | No | Date the device was received at the service center. |
| `promised_date` | DATE | No | Committed delivery date given to customer (received_date + 5 days SLA). |
| `completed_date` | DATE | Yes | Actual completion date. NULL for In Progress and Pending jobs. |
| `technician_id` | VARCHAR | No | ID of assigned technician: `T001`–`T008`. |
| `technician_name` | VARCHAR | Yes (raw) | Name of assigned technician. ~75 rows were blank in raw data — filled in during Silver layer using a technician_id lookup. |
| `repair_notes` | VARCHAR | Yes | Free-text notes on repair status or outcome. ~8% blank in raw data — filled with "No notes provided" in Silver layer. |
| `estimated_cost` | DECIMAL | No | Initial cost estimate provided to customer (INR). Validated to never be negative. |
| `actual_cost` | DECIMAL | Yes | Actual amount charged on completion. NULL for non-Completed jobs. Validated to never be negative. |

---

## 4. Columns Added During the Silver Layer (Not in Raw Data)

| Column Name | Data Type | Description |
|---|---|---|
| `Repair_Duration` | INTEGER | Number of days between `received_date` and `completed_date`. NULL for jobs without a completed_date. |
| `job_status_flag` | VARCHAR | One of `"Delayed"`, `"On Time"`, or `"Not Completed"`, based on comparing `completed_date` to `promised_date`. |

---

## 5. Gold Layer Tables — Column Summary

| Table Name | Key Columns | What It Answers |
|---|---|---|
| `gold_technician_performance` | technician_id, technician_name, total_jobs, completed_jobs, avg_repair_duration_days, delayed_jobs, delay_rate_pct | Which technicians are fastest / need support? |
| `gold_delay_analysis` | avg_delay_days_all_jobs, avg_delay_days_delayed_only, overall_delay_rate_pct | How delayed are jobs, overall? |
| `gold_repeat_customers` | customer_id, customer_name, issue_type, visit_count | Who keeps returning for the same issue? |
| `gold_repeat_customers_overall` | customer_id, customer_name, total_visit_count | Who keeps returning for any reason? |
| `gold_device_brand_analysis` | brand, device_type, issue_type, total_jobs, avg_estimated_cost, avg_actual_cost | Which brands/devices drive the most repair volume? |
| `gold_customer_latest_visit` | customer_id, customer_name, job_id, received_date, job_status, actual_cost | What was each customer's most recent visit? |

---

*This data dictionary should be updated any time a new column is added to the pipeline (e.g., if a new Gold metric is introduced).*
