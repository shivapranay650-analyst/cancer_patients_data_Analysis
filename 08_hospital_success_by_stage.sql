-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 08_hospital_success_by_stage.sql
-- Purpose: Which hospital has the strongest track record of curing/
--          successfully treating patients, broken down by Stage
-- ============================================================

-- IMPORTANT CAVEAT:
-- SQL can only report what already happened in the data - it cannot
-- truly "predict" future outcomes. The Status column only has two
-- values ('Alive' / 'Deceased'), so "success" here is approximated as
-- the % of patients per hospital/stage who are recorded as 'Alive'.
-- Treat this as a historical success-rate ranking, not a forecast.
-- A real prediction (e.g. probability a new patient survives at a
-- given hospital/stage) would need a statistical or machine-learning
-- model trained on this data - SQL can prepare the features, but the
-- actual prediction step happens outside SQL (Python/R, etc.).

-- Step 1: Success rate (Alive %) per hospital, overall
SELECT
    Hospital_Name,
    COUNT(*)                                                  AS total_patients,
    SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END)         AS alive_count,
    ROUND(SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                      AS success_rate_pct
FROM cancer_patients
GROUP BY Hospital_Name
ORDER BY success_rate_pct DESC;

-- Step 2: Success rate per hospital, broken down by Stage
SELECT
    Hospital_Name,
    Stage,
    COUNT(*)                                                  AS total_patients,
    SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END)         AS alive_count,
    ROUND(SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                      AS success_rate_pct
FROM cancer_patients
GROUP BY Hospital_Name, Stage
ORDER BY Stage, success_rate_pct DESC;

-- Step 3: Best-performing hospital for EACH stage
-- (uses a window function to pick the top hospital per stage)
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

-- Step 4: Also factor in average survival months (a second success signal
-- alongside Alive/Deceased status) per hospital and stage
SELECT
    Hospital_Name,
    Stage,
    COUNT(*)                              AS total_patients,
    ROUND(AVG(Survival_Months), 2)        AS avg_survival_months,
    ROUND(SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                  AS success_rate_pct
FROM cancer_patients
GROUP BY Hospital_Name, Stage
ORDER BY Stage, avg_survival_months DESC;
