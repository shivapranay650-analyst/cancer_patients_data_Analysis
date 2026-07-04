
# India Cancer Patients SQL Analysis (2022–2025)

Exploratory SQL analysis of a dataset of 100,000 cancer patient records from
hospitals across India. This started as a way to practice SQL — aggregation,
window functions, time-series trends — on a realistically messy healthcare
dataset, and turned into a full walkthrough of what SQL can tell
you about a dataset like this.

## Dataset

`india_cancer_patients_2022_2025.csv` — 100,000 rows, 12 columns:

| Column | Description |
|---|---|
| Patient_ID | Unique patient identifier |
| Age | Patient age |
| Gender | Male / Female |
| State, City | Location |
| Hospital_Name | One of 10 hospitals |
| Cancer_Type | Type of cancer diagnosed |
| Stage | Stage I–IV |
| Treatment_Type | Treatment administered |
| Diagnosis_Date | Date of diagnosis (2022–2025, small tail into 2026) |
| Survival_Months | Months survived post-diagnosis |
| Status | Alive / Deceased |

## What's in this repo

All scripts are written in standard MySQL syntax.

| Script | What it does |
|---|---|
| `01_table_overview.sql` | Table setup, row/column counts, summary stats, null checks |
| `02_gender_age_analysis.sql` | Gender split and average age by gender |
| `03_remove_duplicates.sql` | Duplicate detection and removal logic |
| `04_stage_distribution_by_age_gender.sql` | Stage distribution across age groups and gender |
| `05_patient_visit_frequency.sql` | First-time vs. repeat-visit patients |
| `06_hospital_repeated_visits.sql` | Hospitals with returning patients |
| `07_hospital_diagnosis_rate.sql` | Diagnosis volume per hospital, over time and by cancer type |
| `08_hospital_success_by_stage.sql` | Hospital "success rate" (Alive %) by stage |
| `09_ranking_and_window_functions.sql` | RANK, ROW_NUMBER, running totals, NTILE bucketing |
| `10_rates_and_ratios.sql` | Success rates, diagnosis share, % of total across various cuts |
| `11_time_trends_and_cohorts.sql` | Diagnoses per year/month, YoY change, cohort breakdowns |


## Findings — and honest caveats

A few things worth knowing before you read too much into any single number:

- **No duplicates, no repeat visits.** Every `Patient_ID` appears exactly
  once in this dataset. `03`, `05`, and `06` are written to handle
  duplicates/repeat visits correctly, but on this specific file they'll
  return empty results — that's expected, not a bug.
- **Hospital volume is almost perfectly even.** All 10 hospitals sit within
  ~150 patients of each other (~10,000 each). There isn't a real "this
  hospital diagnoses way more" story here.
- **"Success rate" is a proxy, not a real outcome measure.** The `Status`
  column only has `Alive` / `Deceased` — there's no `Cured` field — so
  success rate here means % recorded as Alive. Across hospitals this sits
  in a tight band (~36.6%–36.9%), so differences between hospitals are
  small and probably not meaningful on their own.
- **SQL can describe the past, not predict the future.** Anything phrased
  as "which hospital is best at curing X" is really "which hospital had
  the highest historical Alive-rate in this data." A real prediction for
  a new patient would need a statistical/ML model (logistic regression,
  etc.) trained on this data in Python or R — SQL can prepare the features
  for that, but the prediction step itself lives outside SQL.
- **2026 is a partial year.** The data cuts off partway through 2026 (only
  62 records), so any year-over-year chart will show a steep, misleading
  drop for that year unless you exclude it.

The evenness of hospital volumes, the flat success rates, and the complete
absence of duplicate or repeat-visit patients all point toward this being a
synthetically generated dataset rather than raw hospital records — worth
saying so plainly rather than forcing a narrative the data doesn't support.

## Tools used

- SQL (MySQL syntax, tested for SQLite compatibility)
- Dataset: 100,000-row India cancer patient records, 2022–2025
