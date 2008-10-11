library(ggplot2)
h <- read.csv("house-sales.csv", stringsAsFactors = FALSE)

h$br <- as.numeric(h$br)
h$year <- as.numeric(h$year)
h$price <- as.numeric(h$price)

h$datesold <- as.Date(h$datesold, format = "%m-%d-%y")

qplot(price, data=h, geom="histogram", binwidth = 1e4, xlim=c(0, 2e6))
qplot(price - round_any(price, 10000, floor), data=h, geom="histogram", binwidth=100)

qplot(city, data=h, geom="bar")

qplot(datesold, price, data=h, colour=city, geom="line", stat="summary", fun="median")

source("geocode.r")



sf <- subset(h, city %in% "San Francisco")
qplot(datesold, data=sf, geom="bar", binwidth=1)
qplot(datesold, data=sf, geom="bar", binwidth=7)

h$street <- gsub("\\\\", "", h$street)

# addresses <- sf[, c("street", "city", "zip")]
# addresses$lat <- NA
# addresses$long <- NA
# addresses$accuracy <- NA
# addresses$status <- NA
# 
# write.table(unique(addresses), "addresses.csv", sep=",", row=F)