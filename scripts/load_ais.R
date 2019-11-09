library(here)
library(shipr)
source(here("scripts/db_connect.R"))

txt <- file.path(dir_gdata, "ais.sbarc.org/2018 (1)/180101/AIS_SBARC_180101-00.txt")

if (!basename(txt) %in% unique(d$src_txt)){
  # ingest file into db, otherwise skip
  d <- shipr::read_ais_txt(txt)
  d$src_txt <- basename(txt)
  
  # TODO: check for parsing failures -- read_csv(n_max = nLinesOfTxt)
  #  - load into database
  #  - log files entered
  #View(d)
  
  # init
  copy_to(
    con, d, "ais_data", overwrite = T, temporary = F,
    indexes = 
      c("datetime","name","ship_type","mmsi","speed","lon","lat","heading", "src_txt") %>% 
      as.list())
  
  
  
}

#
#cat(paste(names(d), collapse='","'))

# initial copy
# subsequent append
# TODO: check if already there, otherwise skip
dbWriteTable(con, "ais_data", value = d, append=TRUE, row.names=FALSE)

# subsequent querying
tbl_ais <- dbplyr::tbl(con, "ais_data")

d_bupkis <- tbl_ais %>%
  select(datetime, lon, lat) %>%
  filter(name == "bupkis") %>%
  collect()

#read data in

