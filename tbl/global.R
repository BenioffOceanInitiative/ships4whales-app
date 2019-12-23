library(shiny)
library(here)
library(readr)
#library(shipr)
library(DT)

source(here("scripts/db_connect.R"))

ships_csv <- here("cache/ships.csv")

if (!file.exists(ships_csv)){
  tbl(con, "ais_data") %>% 
    collect() %>% 
    write_csv(ships_csv)
}
ships <- read_csv(ships_csv)


