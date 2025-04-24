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