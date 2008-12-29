library(ggplot2)
source("date.r")
source("explore-data.r")
theme_set(theme_bw())

source("finances.r")

# Control for inflation ------------------------------------------------------

geo$month <- month(geo$date)
geo$year <- year(geo$date)

geo <- merge(geo, cpi, by = c("month", "year"), sort = F)
geo$priceadj <- geo$price * geo$ratio

# Add interest rates
irates$date <- NULL
geo <- merge(geo, irates, by = c("month", "year"), sort = F)

# Basic summaries of data --------------------------------------
daily <- ddply(geo, .(date), function(df) {
  data.frame(
    n = nrow(df),
    avg_priceadj = mean(df$priceadj, na.rm = TRUE), 
    avg_price = mean(df$price, na.rm = TRUE),
    cpi = df$cpi[1],
    mprime = df$mprime[1]
  )
}, .progress = "text")

qplot(date, n, data = daily, geom = "line", ylab = "Number of sales") + xlab(NULL)
ggsave(file = "beautiful-data/graphics/daily-sales.pdf", width = 8, height = 4)

qplot(date, avg_price / 1e6, data = daily, geom = "line", ylab = "Average price (millions)") + xlab(NULL)
ggsave(file = "beautiful-data/graphics/daily-price.pdf", width = 8, height = 4)

qplot(date, mprime, data = daily, geom = "line")
qplot(mprime, avg_price, data = daily)
qplot(mprime, n, data = daily)

ggplot(daily, aes(x = date)) + 
  geom_line(aes(y = avg_price / 1e6), colour = "grey60") + 
  geom_line(aes(y = avg_priceadj / 1e6)) + 
  labs(x = NULL, y = "Average price (millions)")
ggsave(file = "beautiful-data/graphics/daily-price-adj.pdf", width = 8, height = 4)

