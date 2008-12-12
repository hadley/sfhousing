if (file.exists("geo.rdata")) {
  load("geo.rdata")
} else {
  ad <- read.csv("addresses.csv", stringsAsFactors = FALSE)
  sales <- read.csv("house-sales.csv", stringsAsFactors = FALSE)

  geo <- merge(sales, ad, by = c("street", "city", "zip"), all.x = TRUE)
  geo$date <- as.Date(strptime(geo$date, "%Y-%m-%d"))
  geo$datesold <- as.Date(strptime(geo$datesold, "%m-%d-%y"))
  geo$price <- as.numeric(geo$price)
  
  save(geo, file = "geo.rdata")
}

# good <- subset(ad, quality == "QUALITY_ADDRESS_RANGE_INTERPOLATION")
# good$quality <- NULL
# good$error <- NULL
# good$success <- NULL

# qplot(long, lat, data=good, shape=I("."))