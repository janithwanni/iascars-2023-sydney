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

set.seed(123)

point_of_interest <- train_data_tour |> filter(new_cause == "lightning") |> slice_sample(n = 1) |> pull(id)

pos_cls_tag <- "Lightning"
neg_cls_tag <- "Not lightning"
pos_color <- "#D72638"
neg_color <- "#C6D8FF"
FRAME_WIDTH <- 600
FRAME_HEIGHT <- 600
point_color <- "#FF0000"
not_point_color <- "#AAAAAA"

fl <- train_data_tour |>
  mutate(disp_cls =
      ifelse(new_cause == "lightning",pos_cls_tag, neg_cls_tag)
  ) |>
  dplyr::select(disp_cls, air_tmax:rh_tmin)

set.seed(123)
center_p <- train_data_tour[point_of_interest,] |> dplyr::select(air_tmax:rh_tmin)
tiny_error <- abs(rnorm(1, sd = 4))
sample_bounds <- map_dfr(seq(2), ~center_p + ((-1)^.x) * tiny_error)

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

sample_data <- rbind(
  gcube$points,
  fl |> dplyr::select(air_tmax:rh_tmin)
)

# highlight point in 3d space along with box
pcv <- rep(not_point_color, nrow(fl))
pcv[point_of_interest] <- point_color
point_color_pal <- c(
  rep("#FFFFFF", nrow(gcube$points)),
  pcv
)
render_gif(
  sample_data,
  grand_tour(),
  display_xy(
    half_range = (sample_bounds |> unlist() |> max()) / 2,
    edges = gcube$edges,
    cex = 0.3,
    col = point_color_pal,
    edges.col = "#DDDDDD",
    axes = "bottomleft",
    edges.width = 0.8
  ),
  gif_file=here::here("talk_slides/imgs/point_box.gif"),
  frames=500,
  width=FRAME_WIDTH,
  height=FRAME_HEIGHT,
  loop=TRUE
)

color_pal <- c(
  rep("#FFFFFF", nrow(gcube$points)),
  ifelse(fl$disp_cls == pos_cls_tag, pos_color, neg_color)
)
render_gif(
  sample_data,
  grand_tour(),
  display_xy(
    edges = gcube$edges,
    cex = 0.3,
    col = color_pal,
    edges.col = "black",
    axes = "bottomleft",
    edges.width = 0.8
  ),
  gif_file=here::here("talk_slides/imgs/box_model.gif"),
  frames=500,
  width=FRAME_WIDTH,
  height=FRAME_HEIGHT,
  loop=TRUE
)

# filter out the data in the box only and make the box edge size smaller

inside_box_fl <- fl |> 
  filter(
    between(air_tmax, sample_bounds$air_tmax[1], sample_bounds$air_tmax[2]),
    between(air_tmin, sample_bounds$air_tmin[1], sample_bounds$air_tmin[2]),
    between(radiation, sample_bounds$radiation[1], sample_bounds$radiation[2]),
    between(rainfall, sample_bounds$rainfall[1], sample_bounds$rainfall[2]),
    between(rh_tmax, sample_bounds$rh_tmax[1], sample_bounds$rh_tmax[2]),
    between(rh_tmin, sample_bounds$rh_tmin[1], sample_bounds$rh_tmin[2]),
  )
inside_box_col_pal <- c(
  rep("#FFFFFF", nrow(gcube$points)),
  ifelse(inside_box_fl$disp_cls == pos_cls_tag, pos_color, neg_color)
)
render_gif(
  rbind(
    gcube$points,
    inside_box_fl |> dplyr::select(air_tmax:rh_tmin)
  ),
  grand_tour(),
  display_xy(
    edges = gcube$edges,
    cex = 2,
    col = inside_box_col_pal,
    edges.col = "black",
    edges.width = 0.1,
    axes = "bottomleft"
  ),
  gif_file = here::here("talk_slides/imgs/inside_box_model.gif"),
  frames = 500,
  width=FRAME_WIDTH,
  height=FRAME_HEIGHT,
  loop=TRUE
)

render_gif(
  rbind(
    gcube$points,
    inside_box_fl |> dplyr::select(air_tmax:rh_tmin)
  ),
  grand_tour(6),
  display_scatmat(),
  gif_file=here::here("talk_slides/imgs/box_scatmat.gif"),
  frames=500,
  width=FRAME_WIDTH,
  height=FRAME_HEIGHT,
  loop=TRUE
)