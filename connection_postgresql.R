

# 1) Important packages ----
library(DBI)
library(dplyr)
library(odbc)


# 2) All data sources ----
data.frame(odbcListDataSources()[[2]][[4]])


# 3) Defining a PostgreSQL DS ----
ds_postgresql <- odbcListDataSources()[[1]][4]


# 4) Checking all drivers ----
drv_all <- sort(unique(odbcListDrivers()[[1]]))


# 5) Defining a PostgreSQL drive ----
drv_postgresql <- drv_all[9]


# 6) Connection ----
con <- dbConnect(odbc::odbc(), 
                 dsn = ds_postgresql,
                 server = "localhost",
                 uid = "postgres",
                 database= "rstudio_test")


# 7) Listing Connected Objects ----
odbcListObjects(con)


# 8) An example data frame to play with ----
iris <- as.data.frame(iris)
summary(iris)


# 9) make names db safe: no '.' or other illegal characters, all lower case and unique ----
dbSafeNames = function(names) {
  names = gsub('[^a-z0-9]+', '_', tolower(names))
  names = make.names(names, unique = TRUE, allow_ = TRUE)
  names = gsub('.', '_', names, fixed = TRUE)
  names
}

colnames(iris) = dbSafeNames(colnames(iris))
summary(iris)

dbWriteTable(con, 'iris', iris, row.names=FALSE)


# 10) Read back the full table: method 1 ----
dtab = dbGetQuery(con, 'select * from iris')
summary(dtab)


# 11) Read back the full table: method 2 ----
rm(dtab)
dtab = dbReadTable(con, 'iris')
summary(dtab)


# 12) Get part of the table ----
rm(dtab)
dtab = dbGetQuery(con, 'select sepal_length, species from iris')
summary(dtab)


# 13) Remove table from database ----
dbSendQuery(con, "drop table iris")


# 14) Disconnect from the database ----
dbDisconnect(con)


# 15) Using dplyr package ----
iris <- con %>%
  tbl('iris')

iris <- as.data.frame(iris)

str(iris)

# 16) Send a query through dplyr ----
query = "select avg(sepal_length) avg_sepal_length, 
                species 
         from iris
         group by species"
dsub = tbl(con, sql(query))
dsub


# 17) Make it local ----
dsub = as.data.frame(dsub)
summary(dsub)
