library(ggplot2)
source("date.r")
source("map.r")
source("explore-data.r")

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
    avg_price = mean(price, na.rm = TRUE)
  ))
}, .progress = "text")
built <- subset(built, n >= 5)

grey_scale <- scale_fill_gradient(low="grey80", high="black")

qplot(long_round, lat_round, data = built, fill = n, geom="tile") + labels + grey_scale + labs(fill = "Number\nof houses")
ggsave(file = "beautiful-data/graphics/sf-bin-n.pdf", width = 8, height = 6)

qplot(long_round, lat_round, data = built, fill = iqr, geom="tile") + labels + grey_scale + labs(fill = "Inter-quartile\nrange")
ggsave(file = "beautiful-data/graphics/sf-bin-iqr.pdf", width = 8, height = 6)

qplot(long_round, lat_round, data = built, fill = avg_year, geom="tile") + labels + grey_scale + labs(fill = "Average\nyear\nbuilt")
ggsave(file = "beautiful-data/graphics/sf-bin-built.pdf", width = 8, height = 6)

qplot(long_round, lat_round, data = built, fill = sqrt(avg_price / 1e6), geom="tile") + labels + grey_scale + labs(fill = "Average\nprice")
ggsave(file = "beautiful-data/graphics/sf-bin-price.pdf", width = 8, height = 6)

