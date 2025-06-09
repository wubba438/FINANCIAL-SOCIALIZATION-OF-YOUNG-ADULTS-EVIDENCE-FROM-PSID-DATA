library(dplyr)
library(knitr)
library(kableExtra)
library(tibble)
library(tidyr)
library(purrr)


# Load data
TAdata <- read.csv("TA_final_reduced_2015.csv", stringsAsFactors = FALSE)

# ------------------------------------------------------------------------------
# STEP 1: Data Cleaning & Variable Construction
# ------------------------------------------------------------------------------

TAdata <- TAdata %>%
  mutate(
    # Income, assets, and employment
    income = ifelse(TA151292 <= 9999997 & TA151292 >=1, TA151292, NA_real_),
    log_income = ifelse(!is.na(income) & income > 0, log(income), NA_real_),
    assets_savings = ifelse(TA151177 < 9999998 & TA151177>-999999, TA151177, NA_real_),
    assets_bonds = ifelse(TA151183 < 99999999 & TA151183>-9999999, TA151183, NA_real_),
    employment_status = ifelse(ER34317 %in% c(1, 2, 3, 5,6,7,8), ER34317, NA_integer_),
    
    # Education & Demographics
    education = ifelse(ER34349 <= 17 & ER34349 > 0, ER34349, NA_integer_),
    age = ifelse(ER34305 <= 125 & ER34305 > 0, ER34305, NA_integer_),
    sex = factor(ER32000, levels = c(1, 2), labels = c("Male", "Female")),
    race = ifelse(TA151132 <= 7, TA151132, NA_integer_),
    marital_status = ifelse(TA151290 <= 8, TA151290, NA_integer_),
    
    # Parent Education
    mother_edu = ifelse(TA151286 <= 17, TA151286, NA_integer_),
    father_edu = ifelse(TA151288 <= 17, TA151288, NA_integer_),
    
    #fianncial behavior
    financial_responsibility = ifelse(TA151270 <= 5, TA151270, NA), #the higher the more responsibility
    financial_responsibility_money_management = ifelse(TA150048 <= 5, TA150048, NA),
    has_credit_card = ifelse(TA151187 == 1, 1, ifelse(TA151187 == 5,0,NA)),
    has_student_loan = ifelse(TA151195 == 1, 1, ifelse(TA151195 == 5,0,NA)),
    
  ) %>%
  # Closeness to parents
  mutate(
    closeness_father = na_if(TA151280, 0),
    closeness_father = na_if(closeness_father, 9),
    closeness_mother = na_if(TA151281, 0),
    closeness_mother = na_if(closeness_mother, 9)
  )

TAdata <- TAdata %>%
  mutate(across(c("TA150049", "TA150051", "TA150066",),~ ifelse(. >= 1 & . <= 7, ., NA)
  ))

TAdata <- TAdata %>%
  mutate(across(c(TA150045, TA150046, TA150047), ~ ifelse(. >= 1 & . <= 5, ., NA)))

TAdata$credit_card_payoff <- ifelse(TAdata$TA150052 >= 1 & TAdata$TA150052 <= 7, TAdata$TA150052,NA) # 0, no credit card

TAdata <- TAdata %>%
  rename(
    responsibility = TA150049, 
    money_management_capability = TA150051, 
    money_worry = TA150066,
    # Add more renaming as needed
  ) 

TAdata <- TAdata %>%
  mutate(across(starts_with("mother_WB16K"), ~ case_when(
    . == 1 ~ 1,
    . == 5 ~ 0,
    . == 2 ~ 0.75,
    TRUE ~ NA_real_
  )))

TAdata <- TAdata %>%
  mutate(across(starts_with("father_WB16K"), ~ case_when(
    . == 1 ~ 1,
    . == 5 ~ 0,
    . == 2 ~ 0.75,
    TRUE ~ NA_real_
  )))

# Parent-level Financial Literacy Scores

TAdata$mother_finlit <- rowSums(
  TAdata[, grep("mother_WB16K", names(TAdata))], 
  na.rm = FALSE
)
TAdata$father_finlit <- rowSums(
  TAdata[, grep("father_WB16K", names(TAdata))], 
  na.rm = FALSE
)
TAdata <- TAdata %>%
  mutate(
    avg_finlit = rowMeans(cbind(mother_finlit, father_finlit), na.rm = TRUE),
    max_finlit = pmax(mother_finlit, father_finlit, na.rm = TRUE)
  )

TAdata <- TAdata %>%
  mutate(
    financial_support = rowSums(across(c(
      house_dummy, rent_dummy, vehicle_dummy, tuition_dummy,
      bills_dummy, loan_dummy, other_dummy
    ), ~ as.numeric(.x)), na.rm = TRUE)
  )
# --- save a version
write.csv(TAdata, "TA_mvprocessed_2015.csv", row.names = FALSE)

TAdata <- read.csv("TA_mvprocessed_2015.csv", stringsAsFactors = FALSE)


# ------------------------------------------------------------------------------
# STEP 2: Fix the datset to be analyzed
# ------------------------------------------------------------------------------
core_vars <- c("education", "age", "sex", "race", "marital_status", "employment_status",
               "income", "father_edu", "mother_edu", "financial_support",
               "credit_card_payoff")

df_clean <- TAdata %>%
  filter(if_all(all_of(core_vars), ~ !is.na(.))) %>%
  mutate(
    # Recode race into two-category variable
    race_cat = case_when(
      race == 1 ~ "White",
      TRUE ~ "Other"
    ),
    
    # Recode race into three-category variable
    race_cat_1 = case_when(
      race == 1 ~ "White",
      race == 2 ~ "Black",
      TRUE ~ "Other"
    ),
    
    # Recode marital status
    marital_cat = case_when(
      marital_status %in% c(1, 3, 4, 6) ~ "Currently Married/cohabiting",
      marital_status %in% c(2, 5, 7, 8) ~ "Not currently married/cohabiting",
    ),
    
    # Recode employment status
    employ_cat = case_when(
      employment_status %in% c(1, 2) ~ "Employed",
      employment_status == 7 ~ "Student",
      employment_status %in% c(3, 5, 6, 8) ~ "Unemployed",
    )
  ) %>%
  # Convert to factors in a second step
  mutate(across(c(race_cat, race_cat_1, marital_cat, employ_cat), ~ factor(.)))

# --- Create subdatasets with explicit variable classification
df_both_finlit <- df_clean %>% filter(!is.na(father_finlit) & !is.na(mother_finlit))
df_either_finlit <- df_clean %>% filter(!is.na(father_finlit) | !is.na(mother_finlit))

# ------------------------------------------------------------------------------
# STEP 3: Regression
# ------------------------------------------------------------------------------
model_clm <- clm(
  ordered(credit_card_payoff) ~ max_finlit + education + age + sex  + log_income
  + race_cat + marital_cat + employ_cat
  + father_edu + mother_edu + closeness_father + closeness_mother + financial_support,
  data =  df_either_finlit
)
summary(model_clm)

# sex stratified regression
df_male <- df_either_finlit  %>% filter(sex == "Male")
df_female <- df_either_finlit  %>% filter(sex == "Female")


# Define the predictor string
predictors <- "father_finlit + mother_finlit + education + age + race_cat + marital_cat + employ_cat + log_income + 
               father_edu + mother_edu + closeness_father + closeness_mother + financial_support"


model_female <- clm(
  formula = as.formula(paste("ordered(credit_card_payoff) ~", predictors)),
  data = df_female
)
summary(model_female)

model_male <- clm(
  formula = as.formula(paste("ordered(credit_card_payoff) ~", predictors)),
  data = df_male
)
summary(model_male)

