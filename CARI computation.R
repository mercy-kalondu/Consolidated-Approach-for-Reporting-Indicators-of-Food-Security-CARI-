
library(dplyr)
library(readxl)
library(writexl)

# Loading the cleaned data
clean_data_path <- "/data.xlsx"
clean_data_nms <- names(readxl::read_excel(path = clean_data_path, n_max = 2000))
clean_c_types <- ifelse(str_detect(string = clean_data_nms, pattern = "_other$"), "text", "guess")
data <- readxl::read_excel(path = clean_data_path, col_types = clean_c_types, na = "NA")
data <- data %>%
  mutate(ecmen1 = ifelse(TotalHHEXP1-(ExpNFKhat + ExpNFOther) > MEB, 1, 0))
# Current Status using FCS and RCSI
data <- data %>%
  mutate(Current_Status = case_when(
    fsl_fcs_cat == "Acceptable" & fsl_rcsi_score < 4 ~ 1,     
    fsl_fcs_cat == "Acceptable" & fsl_rcsi_score >= 4 ~ 2,      
    fsl_fcs_cat == "Borderline" ~ 3,                             
    fsl_fcs_cat == "Poor" ~ 4                                    
  ))

# Assign value labels for Current Status
Current_Status_labels <- c(
  "1" = "Food Secure",
  "2" = "Marginally Food Secure",
  "3" = "Moderately Food Insecure",
  "4" = "Severely Food Insecure"
)

# Convert Current_Status to a factor with labels
data$Current_Status <- factor(data$Current_Status, 
                              levels = c(1, 2, 3, 4), 
                              labels = Current_Status_labels)

# Create new column current_status_numeric with 1, 2, 3, 4 based on Current_Status factor
data <- data %>%
  mutate(current_status_numeric = as.numeric(Current_Status))

# Economic Vulnerability (ECMEN)
# ECMEN Calculation
data <- data %>% 
  mutate(SMEB = ifelse(region == 'bay',80,
                      ifelse(region == 'gedo', 101,
                             ifelse(region == 'hiiran', 72, 
                                    ifelse(region == 'lower_jubba', 69, 
                                           ifelse(region == 'middle_shabelle', 95, 
                                                  ifelse(region == 'sool', 117, NA)))))))
data <- data %>%
  mutate(
    ECMEN = case_when(
      TotalHHEXP1-(ExpNFKhat + ExpNFOther) > MEB ~ 1,  
      TotalHHEXP1-(ExpNFKhat + ExpNFOther) >= SMEB & TotalHHEXP1-(ExpNFKhat + ExpNFOther) <= MEB ~ 3,  
      TotalHHEXP1-(ExpNFKhat + ExpNFOther) <= SMEB ~ 4  
    )
  )


#Classify Livelihood Coping Strategies (LCS)
data <- data %>%
  mutate(LCS_class = case_when(
    LhCSICategory_Name == "Neutral" ~ 1,            
    LhCSICategory_Name == "Stress" ~ 2,             
    LhCSICategory_Name == "Crisis" ~ 3,             
    LhCSICategory_Name == "Emergency" ~ 4         
  ))

# Combine Coping Capacity Components
data <- data %>%
  mutate(Coping_Capacity = pmax(ECMEN, LCS_class, na.rm = TRUE))

# Assign value labels for Coping Capacity
Coping_Capacity_labels <- c(
  "1" = "Food Secure",
  "2" = "Marginally Food Secure",
  "3" = "Moderately Food Insecure",
  "4" = "Severely Food Insecure"
)

# Convert Coping_Capacity to a factor with labels
data$Coping_Capacity <- factor(data$Coping_Capacity, 
                               levels = c(1, 2, 3, 4), 
                               labels = Coping_Capacity_labels)

# Create new column coping_capacity_numeric with 1, 2, 3, 4 based on Coping_Capacity factor
data <- data %>%
  mutate(coping_capacity_numeric = as.numeric(Coping_Capacity))

# Calculate Mean_coping_capacity_ECMEN
# Convert Coping_Capacity and ECMEN to numeric values for calculation

data <- data %>%
  mutate(
    ECMEN_numeric = as.numeric(as.character(ECMEN)),
    Mean_coping_capacity_ECMEN = rowMeans(cbind(coping_capacity_numeric, ECMEN_numeric), na.rm = TRUE)
  )

# Calculate CARI (Comprehensive Approach to Resilience Index)
# Ensure both columns are numeric
data <- data %>%
  mutate(
    Mean_coping_capacity_ECMEN_numeric = as.numeric(as.character(Mean_coping_capacity_ECMEN)), 
    CARI_unrounded_ECMEN = rowMeans(cbind(current_status_numeric, Mean_coping_capacity_ECMEN_numeric), na.rm = TRUE),
    CARI_ECMEN = round(CARI_unrounded_ECMEN)  
  )

# Assign value labels for CARI_ECMEN
CARI_ECMEN_labels <- c(
  "1" = "Food Secure",
  "2" = "Marginally Food Secure",
  "3" = "Moderately Food Insecure",
  "4" = "Severely Food Insecure"
)

# Optional: Convert CARI_ECMEN to a factor with labels
data$CARI_ECMEN <- factor(data$CARI_ECMEN, 
                          levels = c(1, 2, 3, 4), 
                          labels = CARI_ECMEN_labels)

# Write the data to an Excel file
write_xlsx(data, path = "/CARI_results.xlsx")

