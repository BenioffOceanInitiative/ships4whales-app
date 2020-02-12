shinyServer(function(input, output) {
  
  output$map <- renderLeaflet({
    
    #mmsi <- input$mmsi
    mmsi <- "248896000"
    url <- glue("http://api.ships4whales.org/ship_segments?mmsi={mmsi}")
    
    read_sf(url) %>% 
      leaflet() %>% 
      addProviderTiles(providers$Esri.OceanBasemap) %>% 
      addPolylines()

  })
  
  output$mmsi_val <- renderText({ input$mmsi })
})
