library(tidyverse)
library(leaflet)
library(RColorBrewer)
library(maptools)
library(sf)
library(sp)
#library(gstat)
library(rgdal)
#library(rgeos)
#library(tmap)
library(raster)
library(dplyr)
library(shiny)
library(shinydashboard)
library(RPostgreSQL)
library(dbplyr)
library(lubridate)
library(units)
library(here)

# db con ----
#source(here("scripts/db_connect.R"))

# vars ----
dir_cache <- here("cache")
tmp_rdata <- file.path(dir_cache, "tmp.Rdata")

# functions ----
get_length_km <- function(segment){
  # seg <- p$segment[2]
  if (is.na(segment)) return(NA)
  
  st_length(segment) %>%
    set_units("km") %>%
    drop_units()
}

get_segment <- function(p1, p2, crs=4326){
  
  if (any(is.na(p1), is.na(p2))) return(NA)
  
  st_combine(c(p1, p2)) %>%
    st_cast("LINESTRING") %>%
    st_set_crs(crs)
}

# pre-process ----
dir.create(dir_cache, showWarnings = F)

if (!file.exists(tmp_rdata)){
  df_postgres <- dbGetQuery(con, "SELECT datetime, name, mmsi, speed, lon, lat from ais_data WHERE datetime > '2018-11-01'")

  df=df_postgres[order(df_postgres$datetime, df_postgres$name),]
  
  df =df[!(is.na(df$lon) | df$lon=="NULL" | is.na(df$lat) | df$lat=="NULL"),] 
  
  df$speed = as.numeric(df$speed)
  
  pts <- df %>%
    # filter to single vessel
    #filter(name == c("MSC AZOV","SEALAND GUAYAQUIL", "MILLENNIUMSTAR")) %>%
    # convert to sf points tibble
    st_as_sf(coords = c("lon", "lat"), crs=4326) %>%
    # sort by datetime
    arrange(name) %>%
    # filter to only one point per minute to reduce weird speeds
    filter(!duplicated(round_date(datetime, unit="minute"))) %>%
    mutate(
      # get segment based on previous point
      seg      = map2(lag(geometry), geometry, get_segment),
      seg_mins = (datetime - lag(datetime)) %>% as.double(units = "mins"),
      seg_km   = map_dbl(seg, get_length_km),#giving warning
      seg_kmhr = seg_km / (seg_mins / 60),
      seg_new  = if_else(is.na(seg_mins) | seg_mins > 60, 1, 0),
      #apply speed over ground to next segment
      seg_sog = speed*1.852)
  
  
  # setup lines
  lns <- pts %>%
    filter(seg_km <=100) %>%
    filter(!is.na(seg_sog)) %>%
    filter(seg_new == 0) %>%
    #group_by(name) %>%
    mutate(
      seg_geom = map(seg, 1) %>% st_as_sfc(crs=4326)) %>%
    st_set_geometry("seg_geom") 
  
  lns$seg_sog = as.numeric(lns$seg_sog)
  
  save(df, pts, lns, file = tmp_rdata)
}
load(tmp_rdata)

ship_shp <- read_sf("shiny_ships/shapefiles/ship_lane_2013.shp")
st_crs(ship_shp)

sanctuary_shp <- read_sf("shiny_ships/shapefiles/cinms1.shp")
st_crs(sanctuary_shp)

# ui ----
ui <- dashboardPage(
  
  #setting up shiny dashboard layout  
  dashboardHeader(title = "Whale Crossing Guard 3000",titleWidth = 450),
  #setup sidebar layout
  dashboardSidebar(
    sidebarMenu(
      menuItem("Report Cards", tabName = "tbl_b", icon = icon("dashboard")),
      #menuitem 'ship map' which will have the map. 
      menuItem("AIS Map", tabName = "cinms", icon=icon("map"),startExpanded = FALSE),
      #year dropdown which uses year column
      selectInput(inputId = "ship",                                   
                  label="Vessel:",
                  #selected = "2018",
                  choices = sort(unique(lns$name))),
      #sliderInput(inputId = "month",
      # label="Month:",
      #min = 1, max=12,
      #value = c(1,12)),
      
      #setup an about menuitem to explain what the data is about
      menuItem("About", tabName = "about", icon = icon("angellist"))
    )),
  
  #connects sidebar items with 'dashboard body' 
  #uses a lil html stylin to make the layout nice.
  body<-dashboardBody(
    tags$style(type = "text/css", "#cinms {height: calc(100vh - 80px) !important;}"),
    #tabitems need to match ones made above. i.e. "menuItem("Whale Map", tabName = "cinms" needs to match "tabItem(tabName="cinms"
    tabItems(
      
      tabItem(tabName="tbl_b",
              fluidRow(
                box(align="center",
                    title = "Vessel report",
                    collapsible = TRUE,
                    #background = "blue",
                    width = "100%",
                    height = "2000px",tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                    DT::dataTableOutput('tbl_b')
                ))),
      
      tabItem(tabName="cinms",
              fluidRow(
                box(align="center",
                    title = "Vessel Map",
                    collapsible = TRUE,
                    background = "blue",
                    width = "100%",
                    height = "2000px",tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                    leafletOutput("cinms")
                )))
      
    )
  )
)

# server ----

server <- function(input, output, session) {
  
  output$tbl_b = DT::renderDataTable(lns)
  #whaleicon=icons("whale_icon.png")
  
  #render leaflet map
  output$cinms <- renderLeaflet({ 
    #Creates 'dynamic df' for the leaflet map, reference this 'reactive df in all code below
    cinms_map<-lns %>% 
      filter(name==input$ship) #%>% 
    #filter(year==input$year) #%>%  
    # filter(month==input$month)
    
    #set up labels for map datapoints. There's a lot of crazy wayss to do this so...
    pal1 <- leaflet::colorNumeric(palette="Spectral", cinms_map$seg_sog, reverse=T)
    
    #create leaflet map
    leaflet(cinms_map) %>%
      addTiles() %>%
      addProviderTiles(providers$Esri.NatGeoWorldMap) %>% 
      leaflet::addPolylines(
        color = ~pal1(seg_sog),
        label = ~sprintf("%0.03f km/hr on %s", seg_sog, datetime, name), group="sog") %>%
      leaflet::addLegend(
        pal = pal1, values = ~seg_sog, title = "Speed (km/hr)") %>% 
      addPolygons(data = ship_shp, 
                  fillColor = 'blue', 
                  group = "Shipping Lane") %>% 
      addPolygons(data = sanctuary_shp, 
                  fillColor = 'blue', 
                  group = "Sanctuary") %>% 
      addLayersControl(overlayGroups = c("Shipping Lane", "Sanctuary"), 
                       options = layersControlOptions(collapsed = T))
  })
  
}
#seal the deal
shinyApp(ui, server)
