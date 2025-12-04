library(tidyverse)
library(janitor)

# -----------------------------
# Paths: use relative paths
# -----------------------------
input_file  <- file.path("source_data", "melb_data.csv")
output_dir  <- "derived_data"
output_file <- file.path(output_dir, "melb_cleaned.rds")

# create derived_data/ if needed
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# -----------------------------
# Load raw CSV
# -----------------------------
melb <- read_csv(input_file, show_col_types = FALSE)

# ---- Standardize column names ----
melb <- melb %>%
  janitor::clean_names()

# ---- Trim whitespace for character columns ----
melb <- melb %>%
  mutate(across(where(is.character), ~ str_trim(.)))

# ---- Convert factors where appropriate ----
melb <- melb %>%
  mutate(
    type        = factor(type),
    method      = factor(method),
    regionname  = factor(regionname),
    councilarea = factor(council_area)
  )

# ---- Remove rows with critical missing values ----
melb_clean <- melb %>%
  drop_na(price, rooms, bathroom, landsize,
          building_area, distance, type, method)

# ---- Optional: Remove obvious impossible values ----
melb_clean <- melb_clean %>%
  filter(
    price > 0,
    landsize > 0,
    building_area > 0
  )

# ---- Save cleaned data ----
saveRDS(melb_clean, output_file)

message("Saved cleaned dataset to: ", normalizePath(output_file))

