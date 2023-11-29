var sub_map = new Array(12).fill(null);
$(() => {
  Shiny.addCustomMessageHandler('main_map_center', function(event) {
    // console.log(event);
    for(let i = 0;i < 12; i++) {
      // console.log(sub_map[i]);
      sub_map[i].panTo([event.lat, event.lng])
    }
  })

  Shiny.addCustomMessageHandler('main_map_bounds', function(event) {
    // console.log(event);
    for(let i = 0;i < 12; i++) {
      // console.log(sub_map[i]);
      sub_map[i].fitBounds([[event.north, event.east], [event.south, event.west]])
    }
  })

  Shiny.addCustomMessageHandler('main_map_zoom', function(event) {
    // console.log(event);
    for(let i = 0;i < 12; i++) {
      // console.log(sub_map[i]);
      sub_map[i].setZoom(event)
    }
  })
})
