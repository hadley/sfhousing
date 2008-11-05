ad <- read.csv("addresses.csv", stringsAsFactors = FALSE)

good <- subset(ad, quality == "QUALITY_ADDRESS_RANGE_INTERPOLATION")
good$quality <- NULL
good$error <- NULL
good$success <- NULL

qplot(long, lat, data=good, shape=I("."))
ggsave(file = "addresses.png", dpi=300)


sales <- read.csv("house-sales.csv", stringsAsFactors = FALSE)


geocoded <- merge(sales, good, by = c("street", "city", "zip"))
geocoded$year <- as.numeric(geocoded$year)
geocoded$year[geocoded$year < 1850 | geocoded$year > 2007] <- NA

qplot(long, lat, data=subset(geocoded, city == "San Francisco"), colour = year, xlim=c(-122.51, -122.38), ylim=c(37.7, 37.8), size=I(0.5))

sf <- subset(geocoded, long > -122.51 & long < -122.38 & lat > 37.7 & lat < 37.8)
ggplot(sf, aes(long, lat)) + stat_bin2d(bins=50)
qplot(long, lat, data=sf, colour = year, size=I(0.5))
