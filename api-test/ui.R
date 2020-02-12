library(shiny)

shinyUI(fluidPage(
  
  titlePanel("WhaleSafe API test"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("mmsi", "mmsi", value="248896000"),
      verbatimTextOutput("mmsi_val")),
    
    mainPanel(
      leafletOutput("map")))
  
))
