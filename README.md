#  Medicaid Managed Care Analysis using SQL
for Arizona, Michigan, Nevada, and New Mexico (Q1 2025)

![Medicaid Image](https://github.com/araghavan22/Medicaid_Managed_Care_SQL_Analysis/blob/main/Medicaid-image.jpeg)

## Project Overview
This project performs SQL-based analysis on the Medicaid Managed Care dataset provided by the Centers for Medicare & Medicaid Services (CMS). 
The dataset utilizes Transformed Medicaid Statistical Information System (T-MSIS) data for **Arizona, Michigan, Nevada, and New Mexico**. 
It focuses on generating metrics to compare managed care plans within these states across specific specialty areas, currently including **Pediatric Dental, Behavioral Health, and Prenatal OB/GYN**.

The primary goal is to leverage SQL to query, transform, and analyze this data subset to uncover patterns and insights related to managed care plan performance.

## 🚀 Objectives
* To utilize SQL queries for data extraction, cleaning, and transformation of the Medicaid Managed Care dataset.
* To calculate and compare key performance metrics for different managed care plans within the specified states (AZ, MI, NV, NM).
* To analyze variations in plan performance across different specialty areas (Pediatric Dental, Behavioral Health, Prenatal OB/GYN).
* To identify trends or significant differences in managed care delivery between the four states included in the dataset.
* To demonstrate proficiency in SQL for data analysis within the healthcare domain.

## 📌 Dataset 
[CMS Medicaid Managed Care Summary Statistics](https://data.cms.gov/summary-statistics-on-use-and-payments/medicare-medicaid-service-type-reports/medicaid-managed-care)

*(Note: This analysis uses a subset of the full T-MSIS data, specifically tailored for the metrics identified in the dataset).*

## Schema

```sql
DROP TABLE IF EXISTS managed_care;
CREATE TABLE managed_care
(
State	VARCHAR(50),
County	VARCHAR(100),
MCO_Name	VARCHAR(100),
Service_Category	VARCHAR(100),
Number_of_active_patients	INT,
Number_of_Eligible_MCO_Patients INT,
Number_of_Providers INT,
Percent_Of_Eligible_Patients_Receiving_Services	VARCHAR(50),
Number_of_Services_per_Active_Patient	INT,
Number_of_Active_Patients_per_Provider	VARCHAR(50),
Calendar_Year	VARCHAR(10),
Plan_Category VARCHAR(100)
)
```
## 20 Business Problems and Solutions

### 1. What is the distribution of the number of active patients across different states and plan categories?
```sql
WITH RankedMCOs AS (
    SELECT
        State,
        MCO_Name,
        Number_of_active_patients,
        ROW_NUMBER() OVER(PARTITION BY State ORDER BY Number_of_active_patients DESC) as rn
    FROM
        managed_care
    WHERE
        Number_of_active_patients IS NOT NULL
        AND County <> 'AllCountiesinState'
        AND MCO_Name <> 'All'
)
SELECT
    State,
    MCO_Name,
    Number_of_active_patients
FROM
    RankedMCOs
WHERE
    rn = 1
ORDER BY  Number_of_active_patients DESC;

```


### 2.  How does the average number of eligible MCO patients vary by state and county?
```sql
SELECT
    State,
    County,
    Round(AVG(Number_of_Eligible_MCO_Patients)) AS Average_Eligible_Patients
FROM
    managed_care
WHERE
        Number_of_active_patients IS NOT NULL
        AND County <> 'AllCountiesinState'
        AND MCO_Name <> 'All'
GROUP BY
    State,
    County
ORDER BY
    State,
    average_eligible_patients DESC;
```



### 3. What are the top 10 service categories that consistently have a higher number of active patients across different MCOs?
```sql
SELECT
    Service_Category, MCO_Name,
   ROUND( AVG(Number_of_active_patients)) AS Average_Active_Patients
FROM
    managed_care
WHERE
    Number_of_active_patients IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    Service_Category, MCO_Name
ORDER BY
    Average_Active_Patients DESC
LIMIT 10;

```



### 4. What is the trend of the total number of active patients over the different calendar years present in the data?
```sql
SELECT
    Calendar_Year,
    SUM(Number_of_active_patients) AS Total_Active_Patients
FROM
    managed_care
WHERE
    Number_of_active_patients IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    Calendar_Year
ORDER BY
    Calendar_Year;
```



### 5. How does the number of providers vary across different states and service categories?
```sql
SELECT
    State, Service_Category, ROUND(AVG(Number_of_Providers)) AS Average_Providers
FROM
    managed_care
WHERE
    Number_of_Providers IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    State, Service_Category
ORDER BY
    State, Service_Category;

```



### 6. Is there a correlation between the number of eligible patients and the number of providers within each county?
```sql
SELECT
    County, CORR(Number_of_Eligible_MCO_Patients, Number_of_Providers) AS Correlation
FROM
    managed_care
WHERE
    Number_of_Eligible_MCO_Patients IS NOT NULL
    AND Number_of_Providers IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    County
ORDER BY
    Correlation DESC;
```



### 7. Which are the top 10 MCOs that have the highest average number of active patients per provider?
```sql
SELECT
    MCO_Name,
    ROUND(AVG(
        CASE
            WHEN POSITION(':' IN Number_of_Active_Patients_per_Provider) > 0 THEN
                CASE
                    WHEN CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 2) AS NUMERIC) = 0 THEN
                        NULL -- Handle division by zero
                    ELSE
                        CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 1) AS NUMERIC) /
                        CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 2) AS NUMERIC)
                END
         END
    )) AS Average_Patients_Per_Provider_Ratio
FROM
    managed_care
WHERE
    Number_of_Active_Patients_per_Provider IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    MCO_Name
HAVING AVG(
        CASE
            WHEN POSITION(':' IN Number_of_Active_Patients_per_Provider) > 0 THEN
                CASE
                    WHEN CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 2) AS NUMERIC) = 0 THEN
                        NULL -- Handle division by zero
                    ELSE
                        CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 1) AS NUMERIC) /
                        CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 2) AS NUMERIC)
                END
         END
    ) IS NOT NULL
ORDER BY
    Average_Patients_Per_Provider_Ratio DESC
LIMIT 10;

```


### 8. Which are the top 10 MCOs that have the lowest average number of active patients per provider?
```sql
SELECT
    MCO_Name,
    ROUND(AVG(
        CASE
            WHEN POSITION(':' IN Number_of_Active_Patients_per_Provider) > 0 THEN
                CASE
                    WHEN CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 2) AS NUMERIC) = 0 THEN
                        NULL -- Handle division by zero
                    ELSE
                        CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 1) AS NUMERIC) /
                        CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 2) AS NUMERIC)
                END
         END
    )) AS Average_Patients_Per_Provider_Ratio
FROM
    managed_care
WHERE
    Number_of_Active_Patients_per_Provider IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    MCO_Name
HAVING AVG(
        CASE
            WHEN POSITION(':' IN Number_of_Active_Patients_per_Provider) > 0 THEN
                CASE
                    WHEN CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 2) AS NUMERIC) = 0 THEN
                        NULL -- Handle division by zero
                    ELSE
                        CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 1) AS NUMERIC) /
                        CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 2) AS NUMERIC)
                END
         END
    ) IS NOT NULL
ORDER BY
    Average_Patients_Per_Provider_Ratio ASC
LIMIT 10;
```



### 9. Has the average number of active patients per provider changed significantly over the different calendar years?
```sql
WITH YearlyAvgRatio AS (
    SELECT
        Calendar_Year,
        AVG(
            CASE
                WHEN POSITION(':' IN Number_of_Active_Patients_per_Provider) > 0 THEN
                    CASE
                        WHEN CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 2) AS NUMERIC) = 0 THEN
                            NULL
                        ELSE
                            CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 1) AS NUMERIC) /
                            CAST(SPLIT_PART(Number_of_Active_Patients_per_Provider, ':', 2) AS NUMERIC)
                    END
                ELSE
                    NULL
            END
        ) AS Average_Patients_Per_Provider_Ratio_Raw
    FROM
        managed_care
    WHERE
        Number_of_Active_Patients_per_Provider IS NOT NULL
        AND MCO_Name <> 'All'
        AND County <> 'AllCountiesinState'
    GROUP BY
        Calendar_Year
)
SELECT
    Calendar_Year,
    ROUND(Average_Patients_Per_Provider_Ratio_Raw, 2) AS Average_Patients_Per_Provider
FROM
    YearlyAvgRatio
WHERE
    Average_Patients_Per_Provider_Ratio_Raw IS NOT NULL
ORDER BY
    Calendar_Year;
```



### 10.What is the average number of services per active patient for each service category?

```sql
SELECT
    Service_Category,
    ROUND(AVG(Number_of_Services_per_Active_Patient),2) AS Average_Services_Per_Active_Patient
FROM
    managed_care
WHERE
    Number_of_Services_per_Active_Patient IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    Service_Category
ORDER BY
    Service_Category;
```

### 11. Are there significant differences in the average number of services per active patient across different states or plan categories?

-- Average services per active patient by State
```sql
SELECT
    State,
    ROUND(AVG(Number_of_Services_per_Active_Patient),2) AS Average_Services
FROM
    managed_care
WHERE
    Number_of_Services_per_Active_Patient IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    State
ORDER BY
    State;
```

-- Average services per active patient by Plan Category
```sql
SELECT
    Plan_Category,
    ROUND(AVG(Number_of_Services_per_Active_Patient),2) AS Average_Services
FROM
    managed_care
WHERE
    Number_of_Services_per_Active_Patient IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    Plan_Category
ORDER BY
    Plan_Category;
```

-- Average services per active patient by State and Plan Category
```sql
SELECT
    State,
    Plan_Category,
    ROUND(AVG(Number_of_Services_per_Active_Patient),2) AS Average_Services
FROM
    managed_care
WHERE
    Number_of_Services_per_Active_Patient IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    State,
    Plan_Category
ORDER BY
    State,
    Plan_Category;
```



### 12. How does the "Percent_Of_Eligible_Patients_Receiving_Services" vary across different MCOs and service categories?

```sql
SELECT
    MCO_Name,
    Service_Category,
	ROUND(AVG(CAST(REPLACE(Percent_Of_Eligible_Patients_Receiving_Services, '%', '') AS DECIMAL(10, 4))),2) AS average_eligible_percent_receiving_services
FROM
    managed_care
WHERE
    Percent_Of_Eligible_Patients_Receiving_Services IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    MCO_Name,
    Service_Category
ORDER BY
    MCO_Name,
    Service_Category;
```


### 13. Is there a relationship between the number of providers and the "Percent_Of_Eligible_Patients_Receiving_Services" within a given area?

```sql
SELECT
    State,
    County,
    CORR(Number_of_Providers,
         ROUND(CAST(REPLACE(Percent_Of_Eligible_Patients_Receiving_Services, '%', '') AS DECIMAL(10, 4)),2) 
        ) AS Correlation_Providers_vs_ServicePercent
FROM
    managed_care
WHERE
    Number_of_Providers IS NOT NULL 
	AND Percent_Of_Eligible_Patients_Receiving_Services IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    State,
    County
ORDER BY
    State,
    County;
```



### 14. Which MCOs consistently have a high "Percent_Of_Eligible_Patients_Receiving_Services" across different service categories and years?

```sql
WITH MCOAvgPercent AS (
    SELECT
        MCO_Name,
        AVG(
            (CAST(REPLACE(Percent_Of_Eligible_Patients_Receiving_Services, '%', '') AS DECIMAL(10, 4)))/ 100.0
        ) AS Avg_Percent_Across_Services_Years,
        COUNT(DISTINCT EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY'))) AS Number_Of_Years,
        COUNT(DISTINCT Service_Category) AS Number_Of_Service_Categories
    FROM
        managed_care
    WHERE
        Percent_Of_Eligible_Patients_Receiving_Services IS NOT NULL
        AND MCO_Name <> 'All'
        AND County <> 'AllCountiesinState'
    GROUP BY
        MCO_Name
    HAVING
        COUNT(DISTINCT EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY'))) > 1
        AND COUNT(DISTINCT Service_Category) > 1
)
SELECT
    MCO_Name,
    Avg_Percent_Across_Services_Years
FROM
    MCOAvgPercent
WHERE
    Avg_Percent_Across_Services_Years >= (SELECT AVG(Avg_Percent_Across_Services_Years) FROM MCOAvgPercent) -- Adjust threshold as needed
ORDER BY
    Avg_Percent_Across_Services_Years DESC;

```


### 15. What is the trend of the total number of active patients within each state over the available calendar years?

-- Trend in the number of active patients by State and Year
```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')) AS Year,
    State,
    SUM(Number_of_active_patients) AS Total_Active_Patients
FROM
    managed_care
WHERE
    Number_of_active_patients IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')),
    State
ORDER BY
    State,
    Year;
```
### 16. What is the trend of the total number of active patients within each county over the available calendar years?

-- Trend in the number of active patients by County and Year
```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')) AS Year,
    County,
    SUM(Number_of_active_patients) AS Total_Active_Patients
FROM
    managed_care
WHERE
    Number_of_active_patients IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')),
    County
ORDER BY
    County,
    Year;
```

### 17. What is the trend of the average number of providers within each state over the available calendar years?
-- Trend in the number of providers by State and Year
```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')) AS Year,
    State,
    AVG(Number_of_Providers) AS Average_Providers
FROM
    managed_care
WHERE
    Number_of_Providers IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')),
    State
ORDER BY
    State,
    Year;
```

###  18. What is the trend of the average number of providers within each county over the available calendar years?

-- Trend in the number of providers by County and Year
```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')) AS Year,
    County,
    AVG(Number_of_Providers) AS Average_Providers
FROM
    managed_care
WHERE
    Number_of_Providers IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')),
    County
ORDER BY
    County,
    Year;
```
###  19. What is the trend of the average number of services per active patient within each state over the available calendar years?

-- Trend in service utilization (average services per active patient) by State and Year
```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')) AS Year,
    State,
    AVG(Number_of_Services_per_Active_Patient) AS Average_Services_Per_Patient
FROM
    managed_care
WHERE
    Number_of_Services_per_Active_Patient IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')),
    State
ORDER BY
    State,
    Year;

```

###  20. What is the trend of the average number of services per active patient within each county over the available calendar years?

-- Trend in service utilization (average services per active patient) by County and Year
```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')) AS Year,
    County,
    AVG(Number_of_Services_per_Active_Patient) AS Average_Services_Per_Patient
FROM
    managed_care
WHERE
    Number_of_Services_per_Active_Patient IS NOT NULL
    AND MCO_Name <> 'All'
    AND County <> 'AllCountiesinState'
GROUP BY
    EXTRACT(YEAR FROM TO_DATE(Calendar_Year, 'YYYY')),
    County
ORDER BY
    County,
    Year;

```

## 📊 Key Analyses
1.  **Data Aggregation:** Calculating summary statistics (e.g., counts, averages, sums) for relevant metrics per plan, state, and specialty.
2.  **Comparative Analysis:** Writing queries to compare performance metrics between different managed care plans within the same state and specialty.
3.  **Cross-State Comparison:** Analyzing how metrics for similar specialties compare across Arizona, Michigan, Nevada, and New Mexico.
4.  **Specialty-Specific Insights:** Developing queries to investigate trends or outliers within the Pediatric Dental, Behavioral Health, and Prenatal OB/GYN service areas.
5.  **Ranking and Filtering:** Using SQL functions (like `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`) to rank plans based on specific criteria and filtering data to focus on particular segments.
6.  *(Optional: Add any other specific SQL techniques used, e.g., window functions, CTEs, joins across different tables if applicable)*

## 🛠 Tech Stack
* **Language:** SQL
* **Database:** [ PostgreSQL]
* *Other Tools: Excel *

## 📈 Results & Insights
* **Top MCOs by Active Patients:** The Managed Care Organizations (MCOs) with the highest number of active patients identified were:
    * Nevada: Liberty
    * Arizona: MercyCare
    * Michigan: DeltaDental
    * New Mexico: PresbyterianHP
* **Top Counties by Active Patients:** The counties with the most active patients were:
    * Arizona: Maricopa
    * Michigan: Wayne
    * Nevada: Clark
    * New Mexico: Bernalillo
* **Top Service Categories by Average Active Patients:** On average, Pediatric Dental had the most active patients, followed by Behavioral Health.
* **Patient Growth Trend (2019-2023):** There was a general increase in the total number of active patients from 2019 to 2023. The year-over-year increases were:
    * 2019-2020: 2.12%
    * 2020-2021: 31.61%
    * 2021-2022: 20.66%
    * 2022-2023: 26.47%
    This growth pattern was variable, not strictly linear or exponential.
* **Top States/Categories by Provider Count:** The highest number of providers were found in:
    * Arizona: Behavioral Health
    * Michigan: Pediatric Dental
    * Nevada: Behavioral Health
    * New Mexico: Behavioral Health
* **Patient-Provider Correlation:** For a majority of counties analyzed, a positive correlation exists between the number of active patients and the number of available providers.
* **Highest Patient-to-Provider Ratios:** Amerigroup and HPOfNevada were identified as the two MCOs with the highest average number of patients per provider.
* **Services per Patient:** Behavioral Health was the service category with the most services utilized per active patient.


## 🤝 Contributing
Contributions are welcome! Feel free to submit issues or pull requests.

## 📜 License
This project is licensed under the MIT License.
