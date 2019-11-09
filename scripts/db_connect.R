library(yaml)
library(dplyr)
library(RPostgres)
library(dbplyr)
library(glue)

loc_usr <- Sys.info()[['user']]
dir_gdata <- case_when(
  loc_usr == "bbest" ~ "/Volumes/GoogleDrive/My Drive/projects/ship-strike/data",
  loc_usr == "mvisalli" ~ "TODO",
  loc_usr == "seang" ~ "TODO")

db_yml <- file.path(dir_gdata, "heroku_db.yml")
db <- yaml.load_file(db_yml)

con <- dbConnect(
  Postgres(),
  dbname   = db$database,
  host     = db$host,
  port     = db$port,
  user     = db$user,
  password = db$password,
  sslmode  = 'require')