# library(ggplot2)
# source("date.r")
# source("explore-data.r")
# 
# Explore the difference between the cheapest and most expensive houses


# Calculate monthly deciles
midmonth <- function(date) {
  mday(date) <- 15
  date
}
deciles <- ddply(geo, .(date = midmonth(date)), function(df) {
  data.frame(
    decile = seq_len(9),
    value = quantile(df$priceadj, seq(0.1, 0.9, by = 0.1)),
    med = median(df$priceadj)
  )
}, .progress = "text")

ggplot(deciles, aes(date, value / 1e6)) +
  geom_line(aes(group = decile, colour = decile)) +
  scale_colour_gradient(low="grey70", high = "grey20") + 
  opts(legend.position = "none") + 
  xlab(NULL) + 
  ylab("Price (millions)")
ggsave(file = "beautiful-data/graphics/decile-raw.pdf", width = 8, height = 4)

# Index
deciles <- ddply(deciles, .(decile), transform, index = value / value[1])
subset(deciles, as.Date(date) == as.Date("2008-11-15"))

# It looks like the most expensive houses have been least affected.  The 
# cheapest houses have been most affected.
ggplot(deciles, aes(date, index)) +
  geom_hline(yintercept = 1, colour="grey50") +
  geom_line(aes(group = decile, colour = decile)) +
  scale_colour_gradient(low="grey70", high = "grey20") + 
  opts(legend.position = "none") + 
  xlab(NULL) + 
  ylab("Proportional change in value")
ggsave(file = "beautiful-data/graphics/decile-ind.pdf", width = 8, height = 4)

# Relative to median house price, expensive houses have become more expensive
# and cheaper houses cheaper:  the variation in prices has increased as a 
# result of the housing crisis
ggplot(deciles, aes(date, value / med)) +
  geom_line(aes(group = decile, colour = decile)) +
  scale_colour_gradient(low="grey70", high = "grey20") +
  opts(legend.position = "none") + 
  xlab(NULL) + 
  ylab("Value relative to median house price")
  
ggsave(file = "beautiful-data/graphics/decile-rel.pdf", width = 8, height = 4)
