library(ggplot2)
source("date.r")
source("map.r")
source("explore-data.r")
theme_set(theme_bw())

# Look at quality first ------------------------------------------------------

as.data.frame(prop.table(table(geo$quality)) * 100)

# Explore distribution of various groupings ----------------------------
qplot(long, lat, data = geo)

labels <- list(
  labs(x = NULL, y = NULL),
  opts(axis.text.x = theme_blank()),
  opts(axis.text.y = theme_blank())
)

loc <- ggplot(geo, aes(long, lat)) + labs(x = NULL, y = NULL)

loc + geom_bin2d(bins = 100) + bayarea
loc + geom_point(shape = ".") + bayarea

loc + geom_point(aes(colour = county), shape = ".")
loc + geom_point(shape = ".") + facet_wrap(~ city)

# Experiment with binning ----------------------------------------------------

source("map.r")
qplot(long, lat, data = geo, xlim=rlong, ylim=rlat, geom="bin2d", binwidth = c(.2,.2)) + camap

# Create 0.2 x 0.2 grid
geo$longr <- round_any(geo$long, 0.2)
geo$latr <- round_any(geo$lat, 0.2)

geo$month <- geo$date
mday(geo$month) <- 15
geo$month <- as.Date(geo$month)

binned <- ddply(geo, .(longr, latr, month), function(df) {
  data.frame(n = nrow(df), avg = mean(df$price, na.rm = T))
}, .progress = "text")

qplot(month, n, data=binned, geom="line", group=interaction(longr,latr))

# Look at geocoded addresses in SF -------------------------------------------
# Can we see how the city has grown?
sf <- subset(geo, county == "San Francisco County" & quality %in% c("QUALITY_ADDRESS_RANGE_INTERPOLATION", "QUALITY_EXACT_PARCEL_CENTROID"))

# 25000 houses
qplot(year, data = sf, binwidth = 1)
qplot(year, data = sf, binwidth = 10)
sf$decade <- paste(round_any(sf$year, 10, floor), "s", sep="")

ggplot(sf, aes(long, lat)) + geom_point(shape = ".") + labels
ggsave(file = "beautiful-data/graphics/sf-geo.pdf", width = 8, height = 6)
ggsave(last_plot() + coord_flip(), file = "beautiful-data/graphics/sf-geo-big.pdf", width = 8, height = 11.5)

# Aggregate into bins and compute summaries -------------------
# This seems to do the best job of showing where the new and old houses
# are.
sf <- within(sf, {
  lat_round <- round_any(lat, 0.005)
  long_round <- round_any(long, 0.005)
})

built <- ddply(sf, .(lat_round, long_round),  function(df) {
  with(df, data.frame(
    n = nrow(df), 
    avg_year = mean(year, na.rm = TRUE),
    sd = sd(year, na.rm = TRUE),
    iqr = IQR(year, TRUE),
    price_avg = mean(price, na.rm = TRUE),
    price_sd = sd(price, na.rm = TRUE),
    price_q1 = quantile(price, 0.1, na.rm = TRUE),
    price_median = median(price, na.rm = TRUE),
    price_q9 = quantile(price, 0.9, na.rm = TRUE)
  ))
}, .progress = "text")
built <- subset(built, n >= 5)

grey_scale <- scale_fill_gradient(low="grey80", high="black")

qplot(long_round, lat_round, data = built, fill = n, geom="tile") +
  grey_scale +
  labels + 
  labs(fill = "Number\nof houses")
ggsave(file = "beautiful-data/graphics/sf-bin-n.pdf", width = 8, height = 6)


sf$loc <- paste(sf$lat, sf$long, sep ="-")
overlaps <- as.data.frame(table(sf$loc))
names(overlaps) <- c("loc", "n")

sf <- merge(sf, overlaps, by = "loc")
ggplot(sf, aes(long, lat, size = n)) + 
  geom_point(stat = "unique", colour = alpha("black", 0.5)) + 
  scale_area(to = c(0.3, 6), breaks = c(1, 50, 100, 200, 252)) +
  labels
ggsave(file = "beautiful-data/graphics/sf-geo-n.pdf", width = 8, height = 6)

# # The large numbers appear to represent apartment buildings
# apt <- subset(sf, loc == "37.786586--122.393573")$street
# aptno <- as.numeric(gsub("355 1st Street( \\\\#)?S?", "", apt))
# length(unique(aptno))

# Explore prices -------------------------------------------------------

qplot(price_avg, price_median, data=built)
qplot(price_median, price_q9 - price_q1, data=built)
qplot(price_median, (price_q9 - price_q1) / price_median, data=built)

qplot(long_round, lat_round, data = built, fill = price_avg / 1e6, geom="tile") + labels + grey_scale + labs(fill = "Average\nprice")
ggsave(file = "beautiful-data/graphics/sf-bin-price.pdf", width = 8, height = 6)


# Locate expensive areas
expensive <- subset(built, price_avg / 1e6 > 1)
ggplot(sf, aes(long, lat)) + 
  geom_point(stat = "unique", size = 0.5) + 
  geom_point(aes(long_round, lat_round, size = price_avg), colour = alpha("red", 0.5), data = expensive) + 
  scale_area(to = c(2, 4))

subset(expensive, lat_round < 37.74)

qplot(long_round, lat_round, data = built, fill = (price_sd) / price_avg, geom="tile") + labels + grey_scale + labs(fill = "c.v.")
ggsave(file = "beautiful-data/graphics/sf-bin-cv.pdf", width = 8, height = 6)


# Explore year built ---------------------------------------------------

qplot(long_round, lat_round, data = built, fill = iqr, geom="tile") + labels + grey_scale + labs(fill = "Inter-quartile\nrange")
ggsave(file = "beautiful-data/graphics/sf-bin-iqr.pdf", width = 8, height = 6)

qplot(long_round, lat_round, data = built, fill = avg_year, geom="tile") + labels + grey_scale + labs(fill = "Average\nyear\nbuilt")
ggsave(file = "beautiful-data/graphics/sf-bin-built.pdf", width = 8, height = 6)

qplot(long_round, lat_round, data = built, fill = sqrt(avg_price / 1e6), geom="tile") + labels + grey_scale + labs(fill = "Average\nprice")
ggsave(file = "beautiful-data/graphics/sf-bin-price.pdf", width = 8, height = 6)
