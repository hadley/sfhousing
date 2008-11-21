library(ggplot2)
source("date.r")
source("explore-data.r")


# Select the biggest cities in terms of numbers of sales
cities <- as.data.frame(table(geo$city))
names(cities) <- c("city", "freq")
big_cities <- subset(cities, freq > 5000)

qplot(freq, reorder(city, freq), data = big_cities)

# Only look at houses in big cities, reduces records to ~ 200,000
inbig <- subset(geo, city %in% big_cities$city)
inbig$month <- inbig$date
mday(inbig$month) <- 15
inbig$month <- as.Date(inbig$month)

# Cutoff first and last months of date because they are incomplete
inbig <- subset(inbig, month > as.Date("2003-04-15") & 
  month < as.Date("2008-10-15"))

# Summarise sales by month and city
bigsum <- ddply(inbig, .(city, month), function(df) {
  data.frame(
    n = nrow(df), 
    avg = mean(df$price, na.rm = T), 
    sd = sd(df$price, na.rm = T),
    med = median(df$price)
  ) 
})


qplot(month, n, data = bigsum, geom = "line", group = city, log="y")
qplot(month, avg, data = bigsum, geom = "line", group = city, log="y")
qplot(month, n * avg, data = bigsum, geom = "line", group = city, log="y")

qplot(year(month), n, data = bigsum, geom = "line", group = month(month), log="y") + facet_wrap(~ city)

