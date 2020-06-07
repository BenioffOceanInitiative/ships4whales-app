shinyServer(function(input, output) {
  
  get_query <- eventReactive(input$btnQuery, {
    
    simplify <- isolate(input$simplify)
    mmsi     <- isolate(input$mmsi)
    date_beg <- isolate(input$date_beg)
    date_end <- isolate(input$date_end)
    bbox     <- isolate(input$bbox)
    
    q <- c()
    
    if (simplify > "")
      q <- c(q, glue("simplify={input$simplify}"))
    
    if (mmsi > "")
      q <- c(q, glue("mmsi={input$mmsi}"))
    
    if (date_beg > "")
      q <- c(q, glue("date_beg={date_beg}"))

    if (date_end > "")
      q <- c(q, glue("date_end={date_end}"))

    if (bbox > "")
      q <- c(q, glue("bbox={bbox}"))
    
    q
  })
  
  get_url <- reactive({
    url <- "http://api.whalesafe.net/ship_segments"
    
    q <- get_query()
    
    if (length(q) > 0){
      q_str <- paste(q, collapse = "&")
      url <- glue("{url}?{q_str}")
    }

    url
  })
  
  get_data <- reactive({
    url <- get_url()
    message(glue("url: {url}"))
    
    #url <- "http://api.ships4whales.org/ship_segments?date_beg=2019-10-01&date_end=2019-10-04"
    #download.file(url, "test.geojson")
    d <- read_sf(url) 
    })
  
  output$map <- renderLeaflet({
    
    #mmsi <- input$mmsi
    #mmsi <- "248896000"
    
    d <- get_data()
    
    #write_sf(d, "data/tmp_segs.geojson")
    #d <- read_sf("data/tmp_segs.geojson")
    
    speed_bins <- c("[0,10]", "(10,12]", "(12,15]", "(15,Inf]")
    d$speed_bin_txt <- factor(
      speed_bins[d$speed_bin_num], speed_bins, ordered = T)
 
    pal <- colorFactor("YlOrRd", d$speed_bin_txt, ordered = T)
    
    leaflet() %>%
      addProviderTiles(
        providers$Esri.OceanBasemap,
        options = providerTileOptions(
          opacity = 0.7)) %>%
      addPolylines(
        data  = d,
        color = ~pal(speed_bin_txt),
        label = ~glue("mmsi {mmsi} @ {timestamp_beg}: {speed_bin_txt} knots"),
        opacity = 0.7) %>%
      addLegend(
        data = d,
        pal  = pal, values = ~speed_bin_txt, title = "Speed bin (knots)")

  })
  
  output$table <- renderDataTable({
    
    d <- get_data()
    datatable(d)
    
  })
  
  output$url <- renderText({ 
    url <- get_url()
    url
  })
})
