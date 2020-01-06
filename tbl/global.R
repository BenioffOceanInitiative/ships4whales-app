library(shiny)
library(here)
library(readr)
#library(shipr)
library(DT)

source(here("scripts/db_connect.R"))

ships_csv <- here("cache/ships.csv")

# memory.limit()
# memory.limit(size=4000)
# If you are running a server version of RStudio, it will be a bit different.
# You will have to change the file /etc/rstudio/rserver.conf and add rsession-memory-limit-mb=4000 to it.

# free -m
# ps aux --sort -rss

if (!file.exists(ships_csv)){
  
  ships <- tbl(con, "ais_data") %>% 
    group_by(mmsi, name, ship_type) %>% 
    summarise(
      nrows_ais   = n(),
      speed_min   = min(speed, na.rm=T),
      speed_max   = max(speed, na.rm=T),
      heading_min = min(heading, na.rm=T),
      heading_max = max(heading, na.rm=T),
      date_beg    = min(datetime, na.rm=T),
      date_end    = max(datetime, na.rm=T),
      lon_min     = min(lon, na.rm=T),
      lon_max     = max(lon, na.rm=T),
      lat_min     = min(lat, na.rm=T),
      lat_max     = max(lat, na.rm=T)) %>% 
    collect()
  
  write_csv(ships, ships_csv)
}
#ships <- read_csv(ships_csv)
# Warning: 6 parsing failures.
# row  col expected          actual                                file
# 10387 mmsi a double A.N. TILLETT    '/srv/shiny-server/cache/ships.csv'
# 10388 mmsi a double US GOV VESSEL   '/srv/shiny-server/cache/ships.csv'
# 10389 mmsi a double US NAVY SHIP 92 '/srv/shiny-server/cache/ships.csv'
# 10390 mmsi a double US WARSHIP      '/srv/shiny-server/cache/ships.csv'
# 10391 mmsi a double US WARSHIP 92   '/srv/shiny-server/cache/ships.csv'
ships <- read_csv(ships_csv, n_max = 10386)


