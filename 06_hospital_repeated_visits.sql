-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 06_hospital_repeated_visits.sql
-- Purpose: Which hospitals have patients who returned more than once
-- ============================================================

-- NOTE: Same caveat as script 05 - in the current dataset every
-- Patient_ID is unique, so no hospital currently has a repeat visit.
-- This script is written to surface them the moment repeat records exist.

-- Step 1: Find (Patient_ID, Hospital_Name) pairs where the same patient
-- visited the same hospital more than once
SELECT
    Hospital_Name,
    Patient_ID,
    COUNT(*) AS visits_at_this_hospital
FROM cancer_patients
GROUP BY Hospital_Name, Patient_ID
HAVING COUNT(*) > 1
ORDER BY visits_at_this_hospital DESC;

-- Step 2: Rank hospitals by total number of repeat-visit patients
WITH repeat_patients AS (
    SELECT Hospital_Name, Patient_ID
    FROM cancer_patients
    GROUP BY Hospital_Name, Patient_ID
    HAVING COUNT(*) > 1
)
SELECT
    Hospital_Name,
    COUNT(*) AS repeat_patient_count
FROM repeat_patients
GROUP BY Hospital_Name
ORDER BY repeat_patient_count DESC;

-- Step 3: Same idea, but for patients who visited ANY hospital more than
-- once (not necessarily the same hospital twice) - useful if patients
-- transfer between hospitals
SELECT
    Patient_ID,
    COUNT(DISTINCT Hospital_Name) AS hospitals_visited,
    COUNT(*)                      AS total_visits
FROM cancer_patients
GROUP BY Patient_ID
HAVING COUNT(*) > 1
ORDER BY total_visits DESC;
