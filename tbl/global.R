library(here)
library(shipr)
library(DT)

source(here("scripts/db_connect.R"))

tbl_ais <- tbl(con, "ais_data")
