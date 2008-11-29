library(ggplot2)
source("date.r")
source("explore-data.r")

# Want to figure out if sales in different price ranges have been affected
# differently.  Need to be careful to distinguish between houses changing
# price and decreasing sales


# Distribution of prices -----------------------------------------------------

# Distribution of price is highly skew-right
qplot(price, data = geo, geom="histogram", binwidth = 1e5)
# and many prices are rounded to nice numbers:
qplot(price, data = geo, geom="histogram", binwidth = 1e4, xlim = c(0, 2e6))

# On the log scale, distribution looks much nicer
qplot(log10(price), data = geo, geom="histogram", binwidth = .1)
qplot(log10(price), data = geo, geom="histogram", xlim=c(5, 6.5), binwidth = .02)

# Does this pattern change over time?
geo$year <- year(geo$date)
geo$month <- month(geo$date)
fp <- geom_freqpoly(aes(y = ..density..), binwidth = .05)
mid <- subset(geo, price > 10^5 & price < 10^6.5)

# 2008 looks like a particularly bad year
ggplot(mid, aes(log10(price))) + fp + aes(colour = factor(year))
# No difference across months
ggplot(mid, aes(log10(price))) + fp + aes(colour = factor(month))

# Pronounced flattening of distribution around Oct 07
ggplot(mid, aes(log10(price))) + fp + facet_grid(year ~ month)


# Bin prices and look at number of sales -------------------------------------

breaks <- quantile(mid$price, seq(0, 1, length = 11))
labels <- unname(breaks[-11] + breaks[-1]) / 2
mid$pricebin <- labels[as.numeric(cut(mid$price, breaks = breaks))]

sales <- ddply(mid, .(year, month, pricebin), function(df) {
  data.frame(n = nrow(df), avg = mean(df$price))
})
sales <- sales[!is.na(sales$price), ]

# Really interesting patterns:
#  * Two inflection points Jan-Feb 2005 and Jan 2008 where total sales drop
#    and stabilise across price bins
#  * Before 2005 cheap houses high selling, afterwards more expensive
#  * After 2008, sales of cheap houses skyrocket
qplot(year + (month - 1) / 12, n, data = sales, geom = "line", group = pricebin, colour = pricebin, xlab = "year") + scale_colour_gradient(low = "red", high = "blue", trans = "log10")

# Patterns of average sale price are harder to interpret because of the
# binning, but suggestive: most expensive houses have dropped in price,
# while cheaper house show increase.
qplot(year + (month - 1) / 12, avg, data = sales, geom = "line", group=pricebin) + facet_grid(pricebin ~ ., scales = "free_y") + geom_smooth(se = F)

deciles <- ddply(mid, .(year, month), function(df) {
  data.frame(
    decile = seq_len(9),
    value = quantile(df$price, seq(0, 1, length = 11)[-c(1, 11)])
  )
})
qplot(year + (month - 1) / 12, value, data = deciles, geom = "line", group=decile)  + geom_hline(intercept = breaks[-c(1, 11)], colour="grey50")

# But most of the original pattern is a result of houses getting cheaper
# so more houses fall into the cheap bracket.

med <- rename(subset(deciles, decile == 5), c("value" = "median"))
med$decile <- NULL

# Relative to median house price, expensive houses have become more expensive
# and cheaper houses cheaper:  the variation in prices has increased as a 
# result of the housing crisis
deciles <- merge(deciles, med)
qplot(year + (month - 1) / 12, log10(value / median), data = deciles, geom = "line", group=decile)