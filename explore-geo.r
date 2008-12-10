library(ggplot2)
source("date.r")
source("explore-data.r")

rlong <- c(-124.5, -113.5)
rlat <- c(32.5, 42.5)

# Make map of region
library(maps)

ca <- data.frame(map("state", xlim = rlong, ylim = rlat, plot = F)[c("x", "y")])
camap <- geom_path(aes(x, y), data = ca, colour=alpha("grey40", 0.5), size = 0.5)

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
sf <- subset(geo, city == "San Francisco" & quality == "QUALITY_ADDRESS_RANGE_INTERPOLATION")

limits <- list(
  xlim(-122.5183, -122.3549), 
  ylim(37.708, 37.8114),
  opts(axis.text.x = theme_blank(), axis.text.y = theme_blank()),
  xlab(NULL), ylab(NULL)
)

# 27000 houses
qplot(year, data = sf, binwidth = 1)
sf$decade <- paste(round_any(sf$year, 10, floor), "s", sep="")

# Show each decade in it's own panel
qplot(long, lat, data = subset(sf, year >= 1900), size=I(0.5), na.rm = T) + facet_wrap(~ decade) + limits

# Show all together, coloured by year
qplot(long, lat, data = subset(sf, year >= 1900), size=I(1), colour=decade) + limits + scale_colour_brewer(pal = "Spectral")

# Aggregate into bins and compute average year
sf <- within(sf, {
  lat_round <- round_any(lat, 0.002)
  long_round <- round_any(long, 0.002)
})

built <- ddply(sf, .(lat_round, long_round),  function(df) {
  data.frame(n = nrow(df), avg_year = mean(df$year, na.rm = TRUE))
}, .progress = "text")

qplot(long_round, lat_round, data = built, fill = avg_year, geom="tile") + limits + scale_fill_gradient(low="white", high="red")

# Match with map
# http://api.openstreetmap.org/api/0.5/map?bbox=-122.5183,37.708,-122.3549,37.8114
