-- Databricks notebook source
-- MAGIC %md
-- MAGIC # 05_SQL_Analytics - Business Query & Reporting Layer
-- MAGIC
-- MAGIC This notebook demonstrates how business users, operations managers, and data analysts can run pure SQL queries on top of the Gold Delta tables.
-- MAGIC
-- MAGIC
-- MAGIC **parameterization:** The thresholds used below (`10.0` in Query 1, `3` in Query 2) match the
-- MAGIC `DELAY_RATE_THRESHOLD_PCT` and `REPEAT_VISIT_MIN_TOTAL` values defined in `00_Config_Utils.ipynb`.
-- MAGIC Plain SQL files can't read Python variables directly, so if these thresholds change in the config
-- MAGIC notebook, update the matching literal values here too — that's why they're called out explicitly
-- MAGIC in each query below instead of being buried in the query logic.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Query 1: Technician Efficiency Analysis
-- MAGIC **Objective**: Identify which technicians close jobs the fastest and who has the highest delay rate.
-- MAGIC

-- COMMAND ----------

-- Query technician metrics and classify performance using CASE
SELECT 
    technician_id,
    technician_name,
    total_jobs,
    completed_jobs,
    ROUND(avg_repair_duration_days, 2) AS avg_repair_days,
    ROUND(delay_rate_pct, 2) AS delay_pct,
    CASE 
        WHEN delay_rate_pct > 10.0 THEN 'Needs Support'
        ELSE 'Optimal Performance'
    END AS performance_status
FROM gold_technician_performance
ORDER BY avg_repair_duration_days ASC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Query 2: Repeat Customer Issue Trends
-- MAGIC **Objective**: Identify customers returning multiple times for the exact same issue category.

-- COMMAND ----------

-- Find the count of repeat occurrences by issue category
SELECT 
    issue_type,
    COUNT(customer_id) AS repeat_customer_count,
    SUM(visit_count) AS total_visits
FROM gold_repeat_customers
GROUP BY issue_type
HAVING SUM(visit_count) > 3
ORDER BY total_visits DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Query 3: Service Delay Performance (SLA Tracking)
-- MAGIC **Objective**: Report overall business SLA metrics (average delay and delay rate).

-- COMMAND ----------

-- Fetch overall delay aggregates
SELECT 
    ROUND(avg_delay_days_all_jobs, 1) AS avg_days_delayed_all_jobs,
    ROUND(avg_delay_days_delayed_only, 1) AS avg_days_delayed_only_late_jobs,
    ROUND(overall_delay_rate_pct, 2) AS business_delay_rate_percentage
FROM gold_delay_analysis;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Query 4: Repair Volume & Costs by Brand and Category
-- MAGIC **Objective**: Find out which device brands and device types are driving repair volumes and cost margins.

-- COMMAND ----------

-- Group repair volumes and calculate costs by brand and type
SELECT 
    brand,
    device_type,
    SUM(total_jobs) AS total_repair_jobs,
    ROUND(AVG(avg_estimated_cost), 2) AS avg_estimated_cost_inr,
    ROUND(AVG(avg_actual_cost), 2) AS avg_actual_cost_inr
FROM gold_device_brand_analysis
GROUP BY brand, device_type
ORDER BY total_repair_jobs DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Query 5: Customer Latest Visit Details using CTE and Joins
-- MAGIC **Objective**: Create a CRM-style summary report of the latest visit status for each customer.

-- COMMAND ----------

-- Query latest customer interaction using ROW_NUMBER and CTE on Silver layer
WITH RankedJobs AS (
    SELECT 
        job_id,
        customer_id,
        customer_name,
        received_date,
        job_status,
        actual_cost,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY received_date DESC, job_id DESC) as rn
    FROM silver_enriched_jobs
)
SELECT 
    customer_id,
    customer_name,
    job_id AS latest_job_id,
    received_date AS latest_visit_date,
    job_status AS latest_status,
    actual_cost AS cost
FROM RankedJobs
WHERE rn = 1
ORDER BY latest_visit_date DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Query 6: Overall Repeat Customers (Any Issue Type)
-- MAGIC **Objective**: Unlike Query 2 (same issue type only), this shows customers who returned
-- MAGIC for ANY reason more than once — a broader view of customer retention.
-- MAGIC **Fix**: New query added on top of the new `gold_repeat_customers_overall` table.

-- COMMAND ----------

-- Fetch overall repeat customers, sorted by highest visit count first
SELECT 
    customer_id,
    customer_name,
    total_visit_count
FROM gold_repeat_customers_overall
ORDER BY total_visit_count DESC;