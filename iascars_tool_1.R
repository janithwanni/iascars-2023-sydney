library(shiny)
library(tidyverse)
library(leaflet)

min_max_scale <- function(x) (x - min(x, na.rm=T)) / (max(x,na.rm=T) - min(x,na.rm=T))

cf_vals <- readRDS("cf_vals_attempt_3.rds") |>
  as_tibble() |>
  pivot_longer(air_tmax:rh_tmin) |>
  group_by(X, Y, month, name) |>
  summarise(value = mean(value)) |> ungroup()

sub_plot_data <- cf_vals |>
  group_by(X, Y, month, name) |>
  summarise(value = mean(value)) |>
  ungroup()

main_plot_data <- cf_vals |>
  group_by(X, Y, name) |>
  summarise(value = mean(value)) |>
  ungroup() |>
  group_by(name) |>
  mutate(value_scaled = min_max_scale(value)) |>
  ungroup()

ui <- bootstrapPage(
  tags$div(
    class = "container-fluid",
    titlePanel("Spatio Temporal patterns"),
    includeCSS("iascars_tool_1.css"),
    includeScript("iascars_tool_1.js"),
    tags$div(
      class = "row map-row",
      column(
        width = 6,
        tags$div(
          class = "main-map-container",
          leafletOutput("main_map", height = "100%")
        )
      ),
      column(
        width = 6,
        tags$div(
          class = "main-circle-container",
          tags$div(
            class = "main-circle",
            tags$div(class = "circle circle-0", "Jan", leafletOutput("map_0", height = "100%")),
            tags$div(class = "circle circle-1", "Feb", leafletOutput("map_1", height = "100%")),
            tags$div(class = "circle circle-2", "Mar", leafletOutput("map_2", height = "100%")),
            tags$div(class = "circle circle-3", "Apr", leafletOutput("map_3", height = "100%")),
            tags$div(class = "circle circle-4", "May", leafletOutput("map_4", height = "100%")),
            tags$div(class = "circle circle-5", "Jun", leafletOutput("map_5", height = "100%")),
            tags$div(class = "circle circle-6", "Jul", leafletOutput("map_6", height = "100%")),
            tags$div(class = "circle circle-7", "Aug", leafletOutput("map_7", height = "100%")),
            tags$div(class = "circle circle-8", "Sep", leafletOutput("map_8", height = "100%")),
            tags$div(class = "circle circle-9", "Oct", leafletOutput("map_9", height = "100%")),
            tags$div(class = "circle circle-10", "Nov", leafletOutput("map_10", height = "100%")),
            tags$div(class = "circle circle-11", "Dec", leafletOutput("map_11", height = "100%"))
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  layers <- cf_vals$name |> unique()
  layer_colors <- c('#1B9E77','#D95F02','#7570B3','#E7298A','#66A61E','#E6AB02','#A6761D')
  names(layer_colors) <- layers

  value_color_palette <- colorNumeric("YlOrRd", domain = c(0,1))

  var_reactive <- reactiveVal("air_tmax")

  output$main_map <- renderLeaflet({
    main_map <- leaflet() |>
      addProviderTiles(providers$Esri.WorldTopoMap) |>
      setMaxBounds(lng1 = 130.95, lng2 = 160.07, lat1 = -30.99, lat2 = -40.16)

    append(list(main_map), as.list(layers)) |>
      reduce(function(x, y) {
        circle_data <- main_plot_data |>
          filter(name == y)
        x |>
          addCircleMarkers(data = circle_data,
                           lat = ~Y, lng = ~X,
                           group = y, radius = 5,
                           color = ~value_color_palette(value_scaled),
                           label = ~round(value,2)
          )
      }) -> final_map
    final_map |>
      addLegend("bottomright",
                pal = value_color_palette,
                values = ~value_scaled,
                data = main_plot_data
      ) |>
      addLayersControl(baseGroups = layers, options = layersControlOptions(collapsed = FALSE)) |>
      htmlwidgets::onRender(
        "
        function(el, x) {
          var main_map = this;
          main_map.on('baselayerchange', function(e) {
            Shiny.setInputValue('base_layer_change', e.name, {priority: 'event'});
          });
        }
        "
      )
  })

  lapply(seq(0,11), function(i) {
    output[[paste0("map_", i)]] <- renderLeaflet({
      req(var_reactive())
      circle_data <- sub_plot_data |>
        filter(name == var_reactive(), month == (i+1))
      if(nrow(circle_data) != 0) {
        circle_data <- circle_data |>
          mutate(value_scaled = min_max_scale(value))
      }
      map_out <- leaflet() |>
        addProviderTiles(providers$Esri.WorldTopoMap)
      if(nrow(circle_data) != 0) {
        map_out <- map_out |>
          addCircleMarkers(data = circle_data,
                           lng = ~X, lat = ~Y,
                           radius = 3,
                           color = ~value_color_palette(value_scaled),
                           label = ~round(value,2)
          )
      }
      map_out <- map_out |>
        htmlwidgets::onRender(
          glue::glue("
          function(el, x) {
            sub_map[{{i}] = this;
          }
          ", .open = "{{")
        )
      return(map_out)
    })
  })

  observeEvent(input$base_layer_change, {
    var_reactive(input$base_layer_change)
    session$sendCustomMessage("main_map_bounds", input$main_map_bounds)
    session$sendCustomMessage("main_map_zoom", input$main_map_zoom)
  })

  # observeEvent(input$main_map_center, {
  #   session$sendCustomMessage("main_map_center", input$main_map_center)
  # })

  observeEvent(input$main_map_bounds, {
    session$sendCustomMessage("main_map_bounds", input$main_map_bounds)
  })

  observeEvent(input$main_map_zoom, {
    session$sendCustomMessage("main_map_zoom", input$main_map_zoom)
  })
}

shinyApp(ui = ui, server = server, options = list(port = 3469, quiet = TRUE))
