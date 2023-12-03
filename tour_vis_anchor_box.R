library(tidyverse)
library(tourr)

# test_tour_data <- list(
#   model_data = model_data,
#   train_data = training_data,
#   testing_data = testing_data
# )
# saveRDS(test_tour_data, "test_tour_data.rds")

tour_data <- readRDS("test_tour_data.rds")

train_data_tour <- tour_data$train_data |> mutate(id = row_number(), .before = 1)

set.seed(234)

point_of_interest <- train_data_tour |> filter(new_cause == "lightning") |> slice_sample(n = 1) |> pull(id)

pos_cls_tag <- "Lightning"
neg_cls_tag <- "Not lightning"
fl <- train_data_tour |>
  mutate(disp_cls =
      ifelse(new_cause == "lightning",pos_cls_tag, neg_cls_tag)
  ) |>
  dplyr::select(disp_cls, air_tmax:rh_tmin)
color_pal <- ifelse(fl$disp_cls == pos_cls_tag, "#FF0000", "#EEEEEE")
set.seed(123)
fl |>
  filter(disp_cls == pos_cls_tag) |>
  dplyr::select(air_tmax:rh_tmin) |>
  map_dfc(~ sort(sample(.x, 2))) -> sample_bounds

expand_grid(
  air_tmax = sample_bounds$air_tmax,
  air_tmin = sample_bounds$air_tmin,
  radiation = sample_bounds$radiation,
  rainfall = sample_bounds$rainfall,
  rh_tmax = sample_bounds$rh_tmax,
  rh_tmin = sample_bounds$rh_tmin
) -> sample_box

gcube <- geozoo::cube.iterate(p = ncol(sample_bounds))

gcube$points <- sample_box

sample_data <- rbind(gcube$points, fl |> dplyr::select(air_tmax:rh_tmin))
render_gif(
  sample_data,
  grand_tour(),
  display_xy(
    edges = gcube$edges,
    cex = 0.3,
    col = color_pal,
    edges.col = "black"
  ),
  gif_file="box_model.gif",
  frames=500,
  width=600,
  height=600,
  loop=TRUE
)