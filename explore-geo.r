library(ggplot2)
source("date.r")
source("explore-data.r")



# Look at geocoded addresses in SF
# Can we see how the city has grown?
qplot(long, lat, data=subset(geo, city == "San Francisco"), colour = year, xlim=c(-122.51, -122.38), ylim=c(37.7, 37.8), size=I(0.5))
