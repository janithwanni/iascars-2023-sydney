# Script to collect weather data
library(tidyverse)
library(weatherOz)
library(furrr)
library(progressr)
plan(multisession, workers = 3)

needed_vars <- c(
  "max_temp",
  "min_temp",
  "rh_tmax",
  "rh_tmin",
  "radiation",
  "rain"
)

distinct_data <- data |>
  distinct(col, row, date)

download_weather_row <- function(inrow, progress_bar) {
  progress_bar()
  file_name <- paste0(rlang::hash(inrow), ".csv")
  if(!file.exists(here::here("data/weathers_gridded/", file_name))) {
    weather_data <- get_data_drill(
      inrow$col,
      inrow$row,
      start_date = inrow$date,
      end_date = inrow$date,
      values = needed_vars,
      api_key = "janithcwanni@gmail.com"
    )
  } else {
    weather_data <- read_csv(here::here("data/weathers_gridded/", file_name), show_col_types = FALSE)
  }
  weather_data <- weather_data |> mutate(col = inrow$col, row = inrow$row, date = inrow$date)
  write_csv(weather_data, here::here("data/weathers_gridded/", file_name))
}

with_progress({
  p <- progressor(steps = nrow(distinct_data))
  split(distinct_data, seq(nrow(distinct_data))) |>
    future_walk(download_weather_row, progress_bar = p)
})

final_data <- imap_dfr(list.files(here::here("data/weathers_gridded/")), function(.x, .y) {
  read_csv(here::here("data/weathers_gridded/", .x), show_col_types = FALSE) |> 
  mutate(id = .y, .before = 1)
})
 
weather_data <- final_data |>
  group_by(id) |>
  slice_head(n = 1) |>
  ungroup() |>
  mutate(loc = longitude + latitude, .after = "latitude") |>
  arrange(desc(loc)) |>
  fill(air_tmax:rh_tmin_source)

saveRDS(weather_data, "weather_gridded_data.rds")
