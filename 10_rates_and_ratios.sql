-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 10_rates_and_ratios.sql
-- Purpose: Success rate, diagnosis share, % of total - any metric
--          expressible as a ratio of counts
-- ============================================================

-- Step 1: Overall success rate (Alive %) across the whole dataset
SELECT
    COUNT(*)                                            AS total_patients,
    SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END)   AS alive_count,
    SUM(CASE WHEN Status = 'Deceased' THEN 1 ELSE 0 END) AS deceased_count,
    ROUND(SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                AS overall_success_rate_pct
FROM cancer_patients;

-- Step 2: Success rate by Hospital
SELECT
    Hospital_Name,
    COUNT(*) AS total_patients,
    ROUND(SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2) AS success_rate_pct
FROM cancer_patients
GROUP BY Hospital_Name
ORDER BY success_rate_pct DESC;

-- Step 3: Success rate by Stage (does survival drop as stage increases?)
SELECT
    Stage,
    COUNT(*) AS total_patients,
    ROUND(SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2) AS success_rate_pct
FROM cancer_patients
GROUP BY Stage
ORDER BY Stage;

-- Step 4: Success rate by Treatment_Type
SELECT
    Treatment_Type,
    COUNT(*) AS total_patients,
    ROUND(SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2) AS success_rate_pct
FROM cancer_patients
GROUP BY Treatment_Type
ORDER BY success_rate_pct DESC;

-- Step 5: Diagnosis share - each hospital's % of total diagnoses
SELECT
    Hospital_Name,
    COUNT(*) AS total_diagnoses,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cancer_patients), 2)
        AS diagnosis_share_pct
FROM cancer_patients
GROUP BY Hospital_Name
ORDER BY diagnosis_share_pct DESC;

-- Step 6: Cancer type share - each cancer type's % of total diagnoses
SELECT
    Cancer_Type,
    COUNT(*) AS total_diagnoses,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cancer_patients), 2)
        AS diagnosis_share_pct
FROM cancer_patients
GROUP BY Cancer_Type
ORDER BY diagnosis_share_pct DESC;

-- Step 7: Gender share within each stage (ratio of M:F per stage)
SELECT
    Stage,
    Gender,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY Stage), 2)
        AS pct_within_stage
FROM cancer_patients
GROUP BY Stage, Gender
ORDER BY Stage, Gender;

-- Step 8: State-wise share of total patients (which states contribute most)
SELECT
    State,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cancer_patients), 2)
        AS pct_of_total
FROM cancer_patients
GROUP BY State
ORDER BY pct_of_total DESC;

-- Step 9: Ratio of Deceased-to-Alive patients per Cancer_Type
-- (a simple risk ratio; values > 1 mean more deaths than survivors)
SELECT
    Cancer_Type,
    SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END)    AS alive_count,
    SUM(CASE WHEN Status = 'Deceased' THEN 1 ELSE 0 END) AS deceased_count,
    ROUND(
        SUM(CASE WHEN Status = 'Deceased' THEN 1 ELSE 0 END) * 1.0
        / NULLIF(SUM(CASE WHEN Status = 'Alive' THEN 1 ELSE 0 END), 0)
    , 2) AS deceased_to_alive_ratio
FROM cancer_patients
GROUP BY Cancer_Type
ORDER BY deceased_to_alive_ratio DESC;
