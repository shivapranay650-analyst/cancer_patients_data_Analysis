-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 11_time_trends_and_cohorts.sql
-- Purpose: Diagnoses per year/month, and cohort-style breakdowns
-- ============================================================

-- Step 1: Diagnoses per year
SELECT
    SUBSTR(Diagnosis_Date, 1, 4) AS diagnosis_year,
    COUNT(*) AS total_diagnoses
FROM cancer_patients
GROUP BY diagnosis_year
ORDER BY diagnosis_year;

-- Step 2: Diagnoses per month (across all years combined)
-- Useful to check for seasonality, e.g. do diagnoses spike in a
-- particular month regardless of year?
SELECT
    SUBSTR(Diagnosis_Date, 6, 2) AS diagnosis_month,
    COUNT(*) AS total_diagnoses
FROM cancer_patients
GROUP BY diagnosis_month
ORDER BY diagnosis_month;

-- Step 3: Diagnoses per year-month (a proper time series, e.g. "2023-07")
SELECT
    SUBSTR(Diagnosis_Date, 1, 7) AS year_month,
    COUNT(*) AS total_diagnoses
FROM cancer_patients
GROUP BY year_month
ORDER BY year_month;

-- Step 4: Year-over-year % change in total diagnoses
WITH yearly AS (
    SELECT
        SUBSTR(Diagnosis_Date, 1, 4) AS diagnosis_year,
        COUNT(*) AS total_diagnoses
    FROM cancer_patients
    GROUP BY diagnosis_year
)
SELECT
    diagnosis_year,
    total_diagnoses,
    LAG(total_diagnoses) OVER (ORDER BY diagnosis_year) AS previous_year_diagnoses,
    ROUND(
        (total_diagnoses - LAG(total_diagnoses) OVER (ORDER BY diagnosis_year)) * 100.0
        / NULLIF(LAG(total_diagnoses) OVER (ORDER BY diagnosis_year), 0)
    , 2) AS pct_change_vs_prior_year
FROM yearly
ORDER BY diagnosis_year;

-- Step 5: Cohort breakdown - group patients by the YEAR they were first
-- diagnosed ("diagnosis cohort"), then see their outcome mix
SELECT
    SUBSTR(Diagnosis_Date, 1, 4) AS diagnosis_cohort_year,
    Status,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (
        PARTITION BY SUBSTR(Diagnosis_Date, 1, 4)
    ), 2) AS pct_within_cohort
FROM cancer_patients
GROUP BY diagnosis_cohort_year, Status
ORDER BY diagnosis_cohort_year, Status;

-- Step 6: Cohort breakdown - average survival months by diagnosis year
-- cohort AND stage (did outcomes improve for later cohorts?)
SELECT
    SUBSTR(Diagnosis_Date, 1, 4) AS diagnosis_cohort_year,
    Stage,
    COUNT(*)                        AS patient_count,
    ROUND(AVG(Survival_Months), 2)  AS avg_survival_months
FROM cancer_patients
GROUP BY diagnosis_cohort_year, Stage
ORDER BY diagnosis_cohort_year, Stage;

-- Step 7: Diagnoses per year, per cancer type - trend lines side by side
SELECT
    SUBSTR(Diagnosis_Date, 1, 4) AS diagnosis_year,
    Cancer_Type,
    COUNT(*) AS total_diagnoses
FROM cancer_patients
GROUP BY diagnosis_year, Cancer_Type
ORDER BY Cancer_Type, diagnosis_year;

-- Step 8: Rolling 3-month moving average of diagnoses (smooths noise
-- out of the month-to-month series)
WITH monthly AS (
    SELECT
        SUBSTR(Diagnosis_Date, 1, 7) AS year_month,
        COUNT(*) AS total_diagnoses
    FROM cancer_patients
    GROUP BY year_month
)
SELECT
    year_month,
    total_diagnoses,
    ROUND(AVG(total_diagnoses) OVER (
        ORDER BY year_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3month_avg
FROM monthly
ORDER BY year_month;

-- NOTE ON THIS DATASET:
-- Diagnosis_Date runs from 2022 through mid-2025 (with a small tail into
-- early 2026), roughly ~25,000 diagnoses per full year - fairly even
-- year-to-year, so don't expect a dramatic growth/decline story here.
-- The moving average and YoY queries above are still useful to include
-- in a portfolio to demonstrate the technique, even if the underlying
-- trend is flat.
