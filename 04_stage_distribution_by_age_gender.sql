-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 04_stage_distribution_by_age_gender.sql
-- Purpose: Disease (Stage) distribution across age groups and gender
-- ============================================================

-- Step 1: Stage distribution by age group
SELECT
    CASE
        WHEN Age < 18            THEN '0-17 (Child)'
        WHEN Age BETWEEN 18 AND 35 THEN '18-35 (Young Adult)'
        WHEN Age BETWEEN 36 AND 55 THEN '36-55 (Middle Age)'
        WHEN Age BETWEEN 56 AND 70 THEN '56-70 (Senior)'
        ELSE '71+ (Elderly)'
    END AS age_group,
    Stage,
    COUNT(*) AS patient_count
FROM cancer_patients
GROUP BY age_group, Stage
ORDER BY age_group, Stage;

-- Step 2: Stage distribution by gender
SELECT
    Gender,
    Stage,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY Gender), 2) AS pct_within_gender
FROM cancer_patients
GROUP BY Gender, Stage
ORDER BY Gender, Stage;

-- Step 3: Combined view - Stage distribution by age group AND gender
SELECT
    CASE
        WHEN Age < 18            THEN '0-17 (Child)'
        WHEN Age BETWEEN 18 AND 35 THEN '18-35 (Young Adult)'
        WHEN Age BETWEEN 36 AND 55 THEN '36-55 (Middle Age)'
        WHEN Age BETWEEN 56 AND 70 THEN '56-70 (Senior)'
        ELSE '71+ (Elderly)'
    END AS age_group,
    Gender,
    Stage,
    COUNT(*) AS patient_count
FROM cancer_patients
GROUP BY age_group, Gender, Stage
ORDER BY age_group, Gender, Stage;

-- Step 4: Average age per stage (a quick way to see which stage skews older/younger)
SELECT
    Stage,
    ROUND(AVG(Age), 2) AS average_age,
    MIN(Age)           AS youngest,
    MAX(Age)           AS oldest,
    COUNT(*)           AS patient_count
FROM cancer_patients
GROUP BY Stage
ORDER BY Stage;
