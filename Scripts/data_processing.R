library(EnvStats)
library(tidyverse)
library(nortest)

library(EnvStats)
library(tidyverse)
library(nortest)

# =========================
# LOAD DATA
# =========================

health_data <- read_csv("cleaned_nutrition_data.csv")

# =========================
# CONSTANTS
# =========================

OBESITY_Q <- "Percent of adults aged 18 years and older who have obesity"
OVERWEIGHT_Q <- "Percent of adults aged 18 years and older who have an overweight classification"

NO_LEISURE_Q <- "Percent of adults who engage in no leisure-time physical activity"
PA_150_Q <- "Percent of adults who achieve at least 150 minutes a week of moderate-intensity aerobic physical activity or 75 minutes a week of vigorous-intensity aerobic activity (or an equivalent combination)"
PA_300_Q <- "Percent of adults who achieve more than 300 minutes a week of moderate-intensity aerobic physical activity or 150 minutes a week of vigorous-intensity aerobic activity (or an equivalent combination)"
MUSCLE_Q <- "Percent of adults who engage in muscle-strengthening activities on 2 or more days a week"
BOTH_Q <- "Percent of adults who achieve at least 150 minutes a week of moderate-intensity aerobic physical activity and engage in muscle-strengthening activities on 2 or more days a week"

FRUIT_Q <- "Percent of adults who report consuming fruit less than one time daily"
VEG_Q <- "Percent of adults who report consuming vegetables less than one time daily"

# =========================
# HELPER FUNCTION
# =========================

get_metric <- function(data, question_text, new_name) {
  data %>%
    filter(question == question_text) %>%
    select(year, !!sym(new_name) := percent)
}

# =========================
# NATIONAL + STATE FILTERING
# =========================

national_overall <- health_data %>%
  filter(
    locationdesc == "National",
    stratificationcategory1 == "Total",
    stratification1 == "Total",
    stratificationcategoryid1 == "OVR",
    stratificationid1 == "OVERALL"
  ) %>%
  select(
    year = yearstart,
    state = locationdesc,
    topic,
    question,
    percent = data_value,
    low_ci = low_confidence_limit,
    high_ci = high_confidence_limit,
    sample_size
  )

state_overall <- health_data %>%
  filter(
    locationabbr != "US",
    stratificationcategory1 == "Total",
    stratification1 == "Total",
    stratificationcategoryid1 == "OVR",
    stratificationid1 == "OVERALL"
  ) %>%
  select(
    year = yearstart,
    state_abbr = locationabbr,
    state = locationdesc,
    topic,
    question,
    percent = data_value
  )

# =========================
# INDICATOR CREATION
# =========================

state_selected <- state_overall %>%
  mutate(
    indicator = case_when(
      str_detect(question, "obesity") ~ "obesity",
      str_detect(question, "overweight classification") ~ "overweight",
      str_detect(question, "fruit less than one") ~ "fruit_lt1",
      str_detect(question, "vegetables less than one") ~ "veg_lt1",
      str_detect(question, "no leisure-time") ~ "no_leisure",
      str_detect(question, "at least 150 minutes") & str_detect(question, "75") &
        !str_detect(question, "muscle") ~ "pa_150",
      str_detect(question, "more than 300 minutes") ~ "pa_300",
      str_detect(question, "muscle-strengthening") &
        !str_detect(question, "at least 150") ~ "muscle_2x",
      str_detect(question, "at least 150") &
        str_detect(question, "muscle") ~ "pa_both",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(indicator))

state_wide <- state_selected %>%
  group_by(year, state_abbr, state, indicator) %>%
  summarize(value = mean(percent, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = indicator, values_from = value)

# =========================
# SUMMARY STATS
# =========================

summary_stats <- state_wide %>%
  pivot_longer(-c(year, state_abbr, state),
               names_to = "variable",
               values_to = "value") %>%
  group_by(variable) %>%
  summarize(
    min = min(value, na.rm = TRUE),
    q1 = quantile(value, 0.25, na.rm = TRUE),
    median = median(value, na.rm = TRUE),
    q3 = quantile(value, 0.75, na.rm = TRUE),
    max = max(value, na.rm = TRUE)
  )

# =========================
# NATIONAL METRICS
# =========================

national_obesity <- get_metric(national_overall, OBESITY_Q, "obesity")
national_overweight <- get_metric(national_overall, OVERWEIGHT_Q, "overweight")

national_no_leisure <- get_metric(national_overall, NO_LEISURE_Q, "no_leisure")
national_150min <- get_metric(national_overall, PA_150_Q, "pa_150")
national_300min <- get_metric(national_overall, PA_300_Q, "pa_300")
national_lifting2x <- get_metric(national_overall, MUSCLE_Q, "muscle_2x")
national_both <- get_metric(national_overall, BOTH_Q, "pa_both")

national_fruit <- get_metric(national_overall, FRUIT_Q, "fruit_lt1")
national_veg <- get_metric(national_overall, VEG_Q, "veg_lt1")

# =========================
# DERIVED METRICS
# =========================

national_excess_weight <- national_obesity %>%
  inner_join(national_overweight, by = "year") %>%
  mutate(excess_weight = obesity + overweight)

combined <- national_overall %>%
  filter(question %in% c(OBESITY_Q, OVERWEIGHT_Q)) %>%
  mutate(
    category = if_else(str_detect(question, "obesity"), "Obesity", "Overweight")
  )