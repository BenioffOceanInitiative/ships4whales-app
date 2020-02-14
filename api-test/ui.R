shinyUI(fluidPage(
  
  titlePanel("WhaleSafe API test"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("mmsi"    , "mmsi (eg 248896000)"),
      textInput("date_beg", "date_beg (eg 2019-10-01)", value = "2019-10-01"),
      textInput("date_end", "date_end (eg 2019-10-07)", value = "2019-10-07"),
      textInput("bbox"    , "bbox (eg -121.0,33.3,-117.5,34.6)"),
      actionButton("btnQuery", "Submit query", icon = icon("refresh"))),
    
    mainPanel(
      leafletOutput("map"),
      verbatimTextOutput("url"),
      dataTableOutput("table")))
  
))
