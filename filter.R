ta_merged <- read.csv("TA_with_mother_father_data_2015.csv")

# Create dummy variables
mutate(
  house_dummy = ifelse(TA150687 == 1, 1, ifelse(TA150687 == 5, 0, NA)),
  rent_dummy = ifelse(TA150681 == 1, 1, ifelse(TA150681 == 5, 0, NA)),
  vehicle_dummy = ifelse(TA150683 == 1, 1, ifelse(TA150683 == 5, 0, NA)),
  tuition_dummy = ifelse(TA150685 == 1, 1, ifelse(TA150685 == 5, 0, NA)),
  bills_dummy = ifelse(TA150687 == 1, 1, ifelse(TA150687 == 5, 0, NA)),
  loan_dummy = ifelse(TA150689 == 1, 1, ifelse(TA150689 == 5, 0, NA)),
  other_dummy = ifelse(TA150691 == 1, 1, ifelse(TA150691 == 5, 0, NA)),
  
  # Replace invalid values with NA for amounts
  house_value = ifelse(house_dummy == 1 & TA150680 < 999998 & TA150680 >= 1, TA150680, 0),
  rent_value = ifelse(rent_dummy == 1 & TA150682 < 999998, TA150682, 0),
  vehicle_value = ifelse(vehicle_dummy == 1 & TA150684 < 999998, TA150684, 0),
  tuition_value = ifelse(tuition_dummy == 1 & TA150686 < 999998, TA150686, 0),
  bills_value = ifelse(bills_dummy == 1 & TA150688 < 999998, TA150688, 0),
  loan_value = ifelse(loan_dummy == 1 & TA150690 < 999998, TA150690, 0),
  other_value = ifelse(other_dummy == 1 & TA150692 < 999998, TA150692, 0),
  
  # Total financial support
  total_support = house_value + rent_value + vehicle_value +
    tuition_value + bills_value + loan_value + other_value
)


# Define the variables you want to keep
keep_vars <- c(
  # Unique identifier
  "ID68",
  
  # Child-level variables (TA respondent)
  "TA151292",     # Income last year
  "ER34349",      # Education years 99,0
  "ER34305",      # Age
  "TA151132",     # Race
  "TA151270",     # Financial responsibility
  "TA151280",     # Closeness to father, aggregate one
  "TA151281",     # Closeness to mother, aggregate one
  "TA151286",     # Mother's education
  "TA151288",     # Father's education
  "TA151290",     # Marital status
  "TA151177",     # Savings
  "TA151183",     # Bonds/CDs
  "TA151187",     # Credit card flag
  "TA151195",     # Student loans
  "TA150679",     # Constructed total financial support
  "ER34317",      # Employment status1237
  "TA150052",
  "TA150049",
  "TA150051",
  "TA150066",
  
  "house_dummy",
  "rent_dummy",
  "vehicle_dummy",
  "tuition_dummy",
  "bills_dummy",
  "loan_dummy",
  "other_dummy",
  
  # Parent-level variables (from merged WB data)
  "mother_WB16K1", "mother_WB16K2", "mother_WB16K3",
  "mother_WB16K4", "mother_WB16K5", "mother_WB16K6",
  "mother_WB16TMSECK", "mother_WB16TOSECK",
  "father_WB16K1", "father_WB16K2", "father_WB16K3",
  "father_WB16K4", "father_WB16K5", "father_WB16K6",
  "father_WB16TMSECK", "father_WB16TOSECK",
  
)

# Subset the dataset
ta_final <- ta_data[, keep_vars]



write.csv(ta_final, "TA_final_reduced_2015_2.csv", row.names = FALSE)
