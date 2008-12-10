library(ggplot2)
library(cluster)
source("date.r")
source("explore-data.r")

# Attempt to cluster into large number of houses based on geographic 
# location and, later, price

weird <- with(geo, is.na(lat) | is.na(long) | lat > 100 | long > -100)
good <- subset(geo, !weird)
loc <- good[c("lat", "long")]

# This only takes a few seconds.
clusters <- clara(loc, k = 100, trace = 1)
# # Takes about 4 hours on my computer
# system.time(clusters <- clara(loc, k = 1000, trace = 1))

good$cl <- clusters$clustering

hulls <- ddply(good, .(cl), function(df) {
  df[chull(df$lat, df$long), c("lat", "long")]
})

qplot(lat, long, data = hulls, group = cl)

