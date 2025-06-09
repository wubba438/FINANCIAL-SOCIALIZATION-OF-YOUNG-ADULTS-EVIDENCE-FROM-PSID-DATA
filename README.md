# Intergenerational Effects of Financial Literacy on Credit Card Payoff Behavior

## Overview

This research project examines how **parental financial literacy influences young adults’ credit card payoff behavior**, with a particular focus on **demographic differences**. The analysis draws on nationally representative data from:

- The **2015 Panel Study of Income Dynamics (PSID) Transition into Adulthood Supplement (TA)**, and
- Matched parental responses from the **2016 Wellbeing and Daily Life Supplement (WDL)**.

Using **ordinal logistic regression models**, the project assesses **intergenerational effects**, highlighting how racial and gender dynamics shape financial behaviors in early adulthood.

### Key Findings

- **Racial disparities** exist in both parental financial literacy and young adults' credit card payoff behavior.
- **Gender-stratified models** reveal that predictors of payoff behavior differ between males and females.
- **Maternal financial literacy** is positively associated with daughters' credit card payoff behavior, but not sons'.

---

## Project Structure

This repository contains three core scripts used in the data processing and analysis pipeline:

### `merge.R`
- Merges the 2015 TA data with the 2016 WDL parental supplement.
- Aligns respondent and parental records for intergenerational analysis.

### `filter.R`
- Selects and retains only the variables necessary for the analysis.
- Ensures a clean and minimal dataset for downstream processing.

### `reg_analysis.R`
- Handles data preprocessing:
  - Missing data treatment
  - Variable recoding
- Runs ordinal logistic regression models, including gender-stratified analyses.

---

## Data Sources

- **Panel Study of Income Dynamics (PSID)**  
  - 2015 Transition into Adulthood Supplement  
  - 2016 Wellbeing and Daily Life Supplement  
  Access requires registration: [https://psidonline.isr.umich.edu/](https://psidonline.isr.umich.edu/)

---

## Requirements

The scripts are written in **R**. Key packages include:

- `dplyr`
- `tidyr`
- `readr`
- `ordinal` *(for ordinal logistic regression)*
- `haven` *(for reading raw PSID files)*

You can install missing packages with:

```r
install.packages(c("dplyr", "tidyr", "readr", "ordinal", "haven"))
