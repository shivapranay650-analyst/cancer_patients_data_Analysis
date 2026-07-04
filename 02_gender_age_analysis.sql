-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 02_gender_age_analysis.sql
-- Purpose: Gender distribution and average age by gender
-- ============================================================

-- Step 1: Number of male and female patients
SELECT
    Gender,
    COUNT(*) AS patient_count
FROM cancer_patients
GROUP BY Gender
ORDER BY patient_count DESC;

-- Step 2: Average age of male and female patients
SELECT
    Gender,
    ROUND(AVG(Age), 2) AS average_age
FROM cancer_patients
GROUP BY Gender
ORDER BY average_age DESC;

-- Step 3 (bonus): Combine both counts and average age in a single result
SELECT
    Gender,
    COUNT(*)            AS patient_count,
    ROUND(AVG(Age), 2)  AS average_age,
    MIN(Age)            AS youngest_patient,
    MAX(Age)            AS oldest_patient
FROM cancer_patients
GROUP BY Gender
ORDER BY patient_count DESC;

-- Step 4 (bonus): Gender split as a percentage of total patients
SELECT
    Gender,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cancer_patients), 2) AS percentage_of_total
FROM cancer_patients
GROUP BY Gender
ORDER BY patient_count DESC;
