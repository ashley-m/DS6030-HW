library(tidyverse)
library(tidymodels)
library(yardstick)
library(future)

plan(multisession)

rf_model <- rand_forest(
  mode = "classification",
  mtry = tune(),
  trees = 500,
  min_n = tune()
) %>%
  set_engine("ranger", importance = "permutation")

workflow <- workflow() %>%
  add_model(rf_model) %>%
  add_recipe(recipe)

set.seed(666)

rf_resamples <- vfold_cv(d_train, v = 5, strata = outcome)

rf_grid <- grid_regular(
  mtry(range = c(5, 20)),
  min_n(range = c(5,10)),
  levels = 4
)

rf_tune <- tune_grid(
  workflow,
  resamples = rf_resamples,
  grid = rf_grid,
  metrics = metric_set(mn_log_loss)
)

best_rf <- rf_tune %>%
  select_best(metric = "mn_log_loss")