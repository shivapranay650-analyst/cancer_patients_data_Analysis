-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 05_patient_visit_frequency.sql
-- Purpose: Identify first-time vs. repeat-visit patients
-- ============================================================

-- NOTE: A "visit" here is inferred from repeated Patient_ID records
-- ordered by Diagnosis_Date. In the current 100,000-row file, every
-- Patient_ID appears exactly once, so this script returns no repeat
-- visits today - it's written to work correctly the moment repeat
-- records (e.g. follow-up diagnoses) are added to the table.

-- Step 1: Rank each patient's records in chronological order
WITH visit_ranked AS (
    SELECT
        Patient_ID,
        Diagnosis_Date,
        Hospital_Name,
        Cancer_Type,
        Stage,
        ROW_NUMBER() OVER (
            PARTITION BY Patient_ID
            ORDER BY Diagnosis_Date ASC
        ) AS visit_number
    FROM cancer_patients
)

-- Step 2: First-time visiting patients (visit_number = 1)
SELECT Patient_ID, Diagnosis_Date, Hospital_Name, Cancer_Type, Stage
FROM visit_ranked
WHERE visit_number = 1
ORDER BY Patient_ID;

-- Step 3: Second-time visiting patients (visit_number = 2)
WITH visit_ranked AS (
    SELECT
        Patient_ID,
        Diagnosis_Date,
        Hospital_Name,
        Cancer_Type,
        Stage,
        ROW_NUMBER() OVER (
            PARTITION BY Patient_ID
            ORDER BY Diagnosis_Date ASC
        ) AS visit_number
    FROM cancer_patients
)
SELECT Patient_ID, Diagnosis_Date, Hospital_Name, Cancer_Type, Stage
FROM visit_ranked
WHERE visit_number = 2
ORDER BY Patient_ID;

-- Step 4: Summary - how many patients had 1, 2, 3+ visits
WITH visit_counts AS (
    SELECT Patient_ID, COUNT(*) AS total_visits
    FROM cancer_patients
    GROUP BY Patient_ID
)
SELECT
    total_visits,
    COUNT(*) AS number_of_patients
FROM visit_counts
GROUP BY total_visits
ORDER BY total_visits;
