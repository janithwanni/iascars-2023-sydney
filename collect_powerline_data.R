library(sf)
powerline_data <- read_sf(here::here(
  "data/Order_20G552/ll_gda2020//esrishape/whole_of_dataset//victoria/VMFEAT/"
))
powerline_filtered <- powerline_data |>
  filter(
    FEATSUBTYP != "power distribution lv",
    VOLTAGE != "6.6 KV",
    VOLTAGE != "11 KV",
    VOLTAGE != "22 KV"
  )

distinct_data <- data |>
  distinct(col, row)

min_dist_mat <- distinct_data |> 
  st_as_sf(coords = c("row", "col"), crs = st_crs(powerline_filtered)) |>
  st_distance(powerline_filtered)

min_dist_vec <- min_dist_mat |> apply(1, min, na.rm = TRUE)

dist_data <- distinct_data |> mutate(min_dist = min_dist_vec / 1000)

saveRDS(dist_data, "min_dist_data.rds")