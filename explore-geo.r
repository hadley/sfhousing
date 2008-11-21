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

# Look at geocoded addresses in SF
# Can we see how the city has grown?
sf <- subset(geo, city == "San Francisco")

qplot(long, lat, data=sf, colour = year, xlim=c(-122.51, -122.38), ylim=c(37.7, 37.8), size=I(0.5))


qplot(long, lat, data = sf, facets = ~ month, xlim=c(-122.51, -122.38), ylim=c(37.7, 37.8), size=I(0.5))