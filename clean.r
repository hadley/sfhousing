library(ggplot2)
h <- read.csv("house-sales.csv", stringsAsFactors = FALSE)

h$br <- as.numeric(h$br)
h$year <- as.numeric(h$year)
h$price <- as.numeric(h$price)

h$datesold <- as.Date(h$datesold, format = "%m-%d-%y")
h$street <- gsub("\\\\", "", h$street)

qplot(price, data=h, geom="histogram", binwidth = 1e4, xlim=c(0, 2e6))
qplot(price - round_any(price, 10000, floor), data=h, geom="histogram", binwidth=100)

qplot(city, data=h, geom="bar")


# Focus on SF --------------------------------------------
ad <- read.csv("addresses.csv")
sf <- merge(sf, ad, by = c("street", "city", "zip"))

sf <- subset(h, city %in% "San Francisco")
qplot(datesold, data=sf, geom="bar", binwidth=1)
qplot(datesold, data=sf, geom="bar", binwidth=7)
qplot(datesold, log10(price), data=sf, geom="boxplot", group=round(datesold))


qplot(long, lat, data = sf, size = I(0.1), ylim=c(37.7, 37.81), colour=price) + scale_colour_gradient(trans = "sqrt")

# addresses <- sf[, c("street", "city", "zip")]
# addresses$lat <- NA
# addresses$long <- NA
# addresses$accuracy <- NA
# addresses$status <- NA
# 
# write.table(unique(addresses), "addresses.csv", sep=",", row=F)