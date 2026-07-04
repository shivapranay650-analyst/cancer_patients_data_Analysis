-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 09_ranking_and_window_functions.sql
-- Purpose: RANK(), ROW_NUMBER(), running totals, top hospital per
--          stage, and percentile-style bucketing
-- ============================================================

-- Step 1: ROW_NUMBER() - give every patient a unique sequence number
-- ordered by Survival_Months (longest survivors first)
SELECT
    Patient_ID,
    Hospital_Name,
    Stage,
    Survival_Months,
    ROW_NUMBER() OVER (ORDER BY Survival_Months DESC) AS survival_rank_overall
FROM cancer_patients
LIMIT 20;

-- Step 2: RANK() vs ROW_NUMBER() - RANK() gives ties the same number
-- and skips the next rank; ROW_NUMBER() always increments by 1.
-- Example: rank hospitals by total patient volume
SELECT
    Hospital_Name,
    COUNT(*) AS total_patients,
    RANK()       OVER (ORDER BY COUNT(*) DESC) AS rank_with_ties,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS row_num_no_ties
FROM cancer_patients
GROUP BY Hospital_Name
ORDER BY total_patients DESC;

-- Step 3: DENSE_RANK() - like RANK() but doesn't skip numbers after a tie
-- Useful for ranking Stage severity within each Cancer_Type by patient count
SELECT
    Cancer_Type,
    Stage,
    COUNT(*) AS patient_count,
    DENSE_RANK() OVER (
        PARTITION BY Cancer_Type
        ORDER BY COUNT(*) DESC
    ) AS stage_rank_within_cancer_type
FROM cancer_patients
GROUP BY Cancer_Type, Stage
ORDER BY Cancer_Type, stage_rank_within_cancer_type;

-- Step 4: Running total - cumulative patient count by diagnosis year
WITH yearly_counts AS (
    SELECT
        SUBSTR(Diagnosis_Date, 1, 4) AS diagnosis_year,
        COUNT(*) AS patients_that_year
    FROM cancer_patients
    GROUP BY diagnosis_year
)
SELECT
    diagnosis_year,
    patients_that_year,
    SUM(patients_that_year) OVER (
        ORDER BY diagnosis_year
    ) AS running_total_patients
FROM yearly_counts
ORDER BY diagnosis_year;

-- Step 5: Running total of successful (Alive) outcomes per hospital,
-- ordered by diagnosis date - shows cumulative "wins" over time
WITH hospital_yearly AS (
    SELECT
        Hospital_Name,
        SUBSTR(Diagnosis_Date, 1, 4) AS diagnosis_year,
        SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END) AS alive_that_year
    FROM cancer_patients
    GROUP BY Hospital_Name, diagnosis_year
)
SELECT
    Hospital_Name,
    diagnosis_year,
    alive_that_year,
    SUM(alive_that_year) OVER (
        PARTITION BY Hospital_Name
        ORDER BY diagnosis_year
    ) AS running_total_alive
FROM hospital_yearly
ORDER BY Hospital_Name, diagnosis_year;

-- Step 6: Top hospital per stage (best success rate), using RANK()
WITH stage_success AS (
    SELECT
        Hospital_Name,
        Stage,
        COUNT(*) AS total_patients,
        ROUND(SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END) * 100.0
              / COUNT(*), 2) AS success_rate_pct,
        RANK() OVER (
            PARTITION BY Stage
            ORDER BY SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) DESC
        ) AS rank_in_stage
    FROM cancer_patients
    GROUP BY Hospital_Name, Stage
)
SELECT Stage, Hospital_Name, total_patients, success_rate_pct
FROM stage_success
WHERE rank_in_stage = 1
ORDER BY Stage;

-- Step 7: Percentile-style bucketing with NTILE()
-- Split all patients into 4 equal-sized groups (quartiles) by Survival_Months
SELECT
    Patient_ID,
    Survival_Months,
    NTILE(4) OVER (ORDER BY Survival_Months) AS survival_quartile
    -- 1 = shortest survival 25%, 4 = longest survival 25%
FROM cancer_patients
ORDER BY Survival_Months;

-- Step 8: Same idea but in 10 buckets (deciles), summarized
WITH deciles AS (
    SELECT
        Patient_ID,
        Survival_Months,
        NTILE(10) OVER (ORDER BY Survival_Months) AS survival_decile
    FROM cancer_patients
)
SELECT
    survival_decile,
    COUNT(*)                       AS patients_in_decile,
    MIN(Survival_Months)           AS min_months,
    MAX(Survival_Months)           AS max_months,
    ROUND(AVG(Survival_Months),2)  AS avg_months
FROM deciles
GROUP BY survival_decile
ORDER BY survival_decile;

-- Step 9: Age percentile bucket per patient (quartile by age instead)
SELECT
    Patient_ID,
    Age,
    NTILE(4) OVER (ORDER BY Age) AS age_quartile
FROM cancer_patients
ORDER BY Age;
