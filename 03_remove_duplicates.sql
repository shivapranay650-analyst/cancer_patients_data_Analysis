-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 03_remove_duplicates.sql
-- Purpose: Identify and remove duplicate records
-- ============================================================

-- Step 1: Check for fully duplicate rows (every column identical)
SELECT
    Patient_ID, Age, Gender, State, City, Hospital_Name,
    Cancer_Type, Stage, Treatment_Type, Diagnosis_Date,
    Survival_Months, Status,
    COUNT(*) AS duplicate_count
FROM cancer_patients
GROUP BY
    Patient_ID, Age, Gender, State, City, Hospital_Name,
    Cancer_Type, Stage, Treatment_Type, Diagnosis_Date,
    Survival_Months, Status
HAVING COUNT(*) > 1;

-- Step 2: Check for duplicate Patient_ID values only
-- (same patient ID appearing more than once, even if other fields differ)
SELECT
    Patient_ID,
    COUNT(*) AS record_count
FROM cancer_patients
GROUP BY Patient_ID
HAVING COUNT(*) > 1;

-- Step 3: Remove fully duplicate rows using ROW_NUMBER()
-- (MySQL 8+/PostgreSQL/SQL Server - works with window functions)
WITH ranked_rows AS (
    SELECT
        ctid,  -- PostgreSQL row identifier; use a surrogate/primary key column in MySQL
        ROW_NUMBER() OVER (
            PARTITION BY Patient_ID, Age, Gender, State, City, Hospital_Name,
                         Cancer_Type, Stage, Treatment_Type, Diagnosis_Date,
                         Survival_Months, Status
            ORDER BY Patient_ID
        ) AS row_num
    FROM cancer_patients
)
DELETE FROM cancer_patients
WHERE ctid IN (
    SELECT ctid FROM ranked_rows WHERE row_num > 1
);

-- ---- MySQL equivalent (no ctid) ----
-- Requires an auto-increment primary key column, e.g. `id`.
-- If your table doesn't have one, add it first:
-- ALTER TABLE cancer_patients ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- DELETE t1 FROM cancer_patients t1
-- INNER JOIN cancer_patients t2
--     ON t1.Patient_ID = t2.Patient_ID
--     AND t1.Age = t2.Age
--     AND t1.Gender = t2.Gender
--     AND t1.Diagnosis_Date = t2.Diagnosis_Date
--     AND t1.id > t2.id;

-- Step 4: Verify no duplicates remain
SELECT
    Patient_ID, COUNT(*) AS cnt
FROM cancer_patients
GROUP BY Patient_ID
HAVING COUNT(*) > 1;

-- NOTE ON THIS DATASET:
-- I ran a duplicate check on the actual 100,000-row file before writing this
-- script. Every Patient_ID is unique and there are zero fully duplicate rows,
-- so Steps 1, 2 and 4 currently return no results. The DELETE logic above is
-- still included so the script is complete and reusable if duplicates are
-- introduced later (e.g. after merging in new data).
