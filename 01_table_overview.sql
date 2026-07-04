-- ============================================================
-- India Cancer Patients Dataset (2022-2025)
-- 01_table_overview.sql
-- Purpose: Create the table and get a first look at the data
-- ============================================================

-- Step 1: Create the table structure
CREATE TABLE cancer_patients (
    Patient_ID       VARCHAR(20),
    Age              INT,
    Gender           VARCHAR(10),
    State            VARCHAR(50),
    City             VARCHAR(50),
    Hospital_Name    VARCHAR(100),
    Cancer_Type      VARCHAR(50),
    Stage            VARCHAR(20),
    Treatment_Type   VARCHAR(50),
    Diagnosis_Date   DATE,
    Survival_Months  DECIMAL(6,1),
    Status           VARCHAR(20)
);

-- Step 2: Load the CSV data
-- (MySQL example — update file path to match your local setup)
LOAD DATA LOCAL INFILE 'india_cancer_patients_2022_2025.csv'
INTO TABLE cancer_patients
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Step 3: Describe the table structure (column names, data types)
DESCRIBE cancer_patients;

-- Step 4: Total number of rows in the table
SELECT COUNT(*) AS total_rows
FROM cancer_patients;

-- Step 5: Total number of columns in the table
SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'cancer_patients';

-- Step 6: Quick preview of the first 10 rows
SELECT *
FROM cancer_patients
LIMIT 10;

-- Step 7: Basic statistical summary (numeric columns)
-- MySQL has no built-in DESCRIBE/SUMMARY function like Python's pandas,
-- so we build it manually for Age and Survival_Months
SELECT
    'Age' AS column_name,
    COUNT(Age)              AS count,
    MIN(Age)                AS min_value,
    MAX(Age)                AS max_value,
    ROUND(AVG(Age), 2)      AS mean_value,
    ROUND(STDDEV(Age), 2)   AS std_dev
FROM cancer_patients

UNION ALL

SELECT
    'Survival_Months' AS column_name,
    COUNT(Survival_Months)             AS count,
    MIN(Survival_Months)               AS min_value,
    MAX(Survival_Months)               AS max_value,
    ROUND(AVG(Survival_Months), 2)     AS mean_value,
    ROUND(STDDEV(Survival_Months), 2)  AS std_dev
FROM cancer_patients;

-- Step 8: Check for missing (NULL) values in each column
SELECT
    SUM(CASE WHEN Patient_ID      IS NULL THEN 1 ELSE 0 END) AS missing_patient_id,
    SUM(CASE WHEN Age             IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN Gender          IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN State           IS NULL THEN 1 ELSE 0 END) AS missing_state,
    SUM(CASE WHEN City            IS NULL THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN Hospital_Name   IS NULL THEN 1 ELSE 0 END) AS missing_hospital,
    SUM(CASE WHEN Cancer_Type     IS NULL THEN 1 ELSE 0 END) AS missing_cancer_type,
    SUM(CASE WHEN Stage           IS NULL THEN 1 ELSE 0 END) AS missing_stage,
    SUM(CASE WHEN Treatment_Type  IS NULL THEN 1 ELSE 0 END) AS missing_treatment,
    SUM(CASE WHEN Diagnosis_Date  IS NULL THEN 1 ELSE 0 END) AS missing_diagnosis_date,
    SUM(CASE WHEN Survival_Months IS NULL THEN 1 ELSE 0 END) AS missing_survival_months,
    SUM(CASE WHEN Status          IS NULL THEN 1 ELSE 0 END) AS missing_status
FROM cancer_patients;
