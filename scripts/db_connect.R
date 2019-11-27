library(yaml)
library(dplyr)
library(RPostgres)
library(dbplyr)
library(glue)

loc_usr <- Sys.info()[['user']]
dir_gdata <- case_when(
  loc_usr == "bbest" ~ "/Volumes/GoogleDrive/My Drive/projects/ship-strike/data",
  loc_usr == "mvisalli" ~ "TODO",
  loc_usr == "seang" ~ "/Volumes/GoogleDrive/My Drive/ship-strike/data")

# create database ----
# psql -h database-1.cbh6z8ln2pdp.us-west-2.rds.amazonaws.com -U postgres
#
# postgres=> CREATE DATABASE ships4whales;
# CREATE DATABASE
# postgres=> CREATE EXTENSION postgis;
# ERROR:  extension "postgis" already exists
# postgres=> CREATE EXTENSION postgis_topology;
# ERROR:  extension "postgis_topology" already exists
# postgres=> CREATE EXTENSION pgrouting;

# connect ----
db_yml <- file.path(dir_gdata, "amazon_rds.yml")
db <- yaml.load_file(db_yml)

con <- dbConnect(
  Postgres(),
  dbname   = db$database,
  host     = db$host,
  port     = db$port,
  user     = db$user,
  password = db$password,
  sslmode  = 'require')

 #dbListTables(con)
#test = dbGetQuery(con, 'select count(*) from ais_data')