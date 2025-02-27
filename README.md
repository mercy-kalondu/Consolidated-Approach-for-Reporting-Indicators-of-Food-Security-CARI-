# Consolidated-Approach-for-Reporting-Indicators-of-Food-Security-CARI
CARI computation
This repository contains an R script for analyzing food security, economic vulnerability, and coping capacity (CARI) based on survey data. The script processes cleaned household survey data, applies classification models (e.g., Food Consumption Score, Livelihood Coping Strategies, and Economic Vulnerability), and computes the Comprehensive Approach to Resilience Index (CARI).
Key Features:
•	Data Import & Cleaning: Reads survey data, assigns appropriate column types, and handles missing values.
•	Food Security Classification: Categorizes households using FCS (Food Consumption Score) and RCSI (Reduced Coping Strategy Index).
•	 Economic Vulnerability Assessment: Computes household expenditure relative to Minimum Expenditure Basket (MEB) and Survival MEB (SMEB) thresholds.
•	Coping Strategy Index: Assigns households to coping strategy categories (Neutral, Stress, Crisis, Emergency).
•	CARI Calculation: Computes and classifies CARI scores to assess overall household food security status.
•	Exporting Results: Outputs the processed dataset with CARI scores to an Excel file for further reporting and visualization.
Technologies Used:
•	R (dplyr, readxl, writexl)
•	Data Processing & Transformation
•	Food Security & Vulnerability Indicators
Usage:
1.	Load cleaned household survey data.
2.	Run the script to process and classify food security and coping strategy indicators.
3.	Export final results to an Excel file for reporting.
