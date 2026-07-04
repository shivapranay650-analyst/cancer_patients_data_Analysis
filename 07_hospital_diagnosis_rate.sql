-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 07_hospital_diagnosis_rate.sql
-- Purpose: Which hospital diagnoses the most patients (diagnosis rate)
-- ============================================================

-- Step 1: Total diagnoses per hospital, ranked
SELECT
    Hospital_Name,
    COUNT(*) AS total_diagnoses,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cancer_patients), 2) AS pct_of_all_diagnoses
FROM cancer_patients
GROUP BY Hospital_Name
ORDER BY total_diagnoses DESC;

-- Step 2: Diagnosis rate per hospital per year
-- (shows whether a hospital's diagnosis volume is rising or falling)
SELECT
    Hospital_Name,
    SUBSTR(Diagnosis_Date, 1, 4) AS diagnosis_year,
    COUNT(*) AS diagnoses_that_year
FROM cancer_patients
GROUP BY Hospital_Name, diagnosis_year
ORDER BY Hospital_Name, diagnosis_year;

-- Step 3: Diagnosis rate per hospital per cancer type
-- (useful to see which hospitals specialize in / see more of a given cancer)
SELECT
    Hospital_Name,
    Cancer_Type,
    COUNT(*) AS diagnoses
FROM cancer_patients
GROUP BY Hospital_Name, Cancer_Type
ORDER BY Hospital_Name, diagnoses DESC;

-- Step 4: Rank hospitals by diagnosis volume using RANK()
SELECT
    Hospital_Name,
    COUNT(*) AS total_diagnoses,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS diagnosis_rank
FROM cancer_patients
GROUP BY Hospital_Name;
