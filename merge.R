# Load libraries
library(readxl)
library(haven)
library(dplyr)

# Load data
ta_data <- read_excel("J348235.xlsx")
parent_data <- read_excel("J348211.xlsx")
fim_map <- read_sas("fim14891_gid_BO_2_BAL_wide.sas7bdat")
ta_data_1 <- read_excel("J348252.xlsx")
ta_data_3 <- read_excel("J348260.xlsx")

# Construct unique IDs
ta_data <- ta_data %>%
  mutate(ID68 = ER30001 * 100 + ER30002)

ta_data_1 <- ta_data_1 %>%
  mutate(ID68 = ER30001 * 100 + ER30002)

ta_data_3 <- ta_data_3 %>%
  mutate(ID68 = ER30001 * 100 + ER30002)

parent_data <- parent_data %>%
  mutate(ID68 = ER30001 * 100 + ER30002)

fim_map <- fim_map %>%
  mutate(ID68_child = ER30001 * 100 + ER30002,
         ID68_father = ER30001_P_F * 100 + ER30002_P_F,
         ID68_mother = ER30001_P_M * 100 + ER30002_P_M)

# Merge FIM into TA to get parental IDs
ta_with_parents <- ta_data %>%
  left_join(fim_map, by = c("ID68" = "ID68_child"))

# Separate mother and father data from parent_data
mother_data <- parent_data %>%
  filter(ER32000 == 2) %>%  # 2 = female
  select(ID68, starts_with("WB16")) %>%
  rename_with(~ paste0("mother_", .), -ID68)

father_data <- parent_data %>%
  filter(ER32000 == 1) %>%  # 1 = male
  select(ID68, starts_with("WB16")) %>%
  rename_with(~ paste0("father_", .), -ID68)

# Merge parent data into child-level file
ta_merged <- ta_with_parents %>%
  left_join(father_data, by = c("ID68_father" = "ID68")) %>%
  left_join(mother_data, by = c("ID68_mother" = "ID68"))


ta_data_2 <- ta_data_1 %>% select(ID68, ER34317)

ta_merged <- ta_merged %>%
  left_join(ta_data_2, by = "ID68")

ta_data_4 <- ta_data_3 %>% select(ID68,TA150051, TA150052, TA150066)

ta_merged <- ta_merged %>%
  left_join(ta_data_4, by = "ID68")

# Save to CSV
write.csv(ta_merged, "TA_with_mother_father_data_2015.csv", row.names = FALSE)

