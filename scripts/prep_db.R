source(here::here("scripts/db_connect.R"))

dbListTables(con)
tbl_ais  <- tbl(con, "ais_data")
tbl_mmsi <- tbl(con, "mmsi")

# TODO: list indexes, if not in indexes
if (F){
  # only do once:
  dbExecute(con, "CREATE INDEX ais_data_mmsi_idx ON ais_data (mmsi);")
  dbExecute(con, "CREATE INDEX ais_data_datetime_idx ON ais_data (datetime);")
}

ships <- tbl_ais %>% 
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

readr::write_csv(ships, here("cache/ships.csv"))

# ais_ships <- ais %>% 
#   group_by(name) %>% 
#   summarize(
#     n = n(),
#     date_beg = min(datetime, na.rm=T),
#     date_end = max(datetime, na.rm=T)) %>% 
#   collect()

dbColumnInfo(tbl_ais)
dbListObjects(con)

