library(ggplot2)
source("date.r")
source("explore-data.r")


# Check difference between date and date sold
both <- subset(geo, !is.na(date) & !is.na(datesold))
diff <- as.numeric(both$date) - as.numeric(both$datesold)
qplot(diff, binwidth = 1)
qplot(diff, geom="histogram", binwidth = 1) + scale_x_continuous("day after sale", breaks = seq(7, 70, by = 7), limits = c(7, 63))
qplot(factor(wday(both$datesold)))

# Want to figure out if sales in different price ranges have been affected
# differently.  Need to be careful to distinguish between houses changing
# price and decreasing sales

# Distribution of prices -----------------------------------------------------

# Distribution of price is highly skew-right
qplot(priceadj, data = geo, geom="histogram", binwidth = 1e5)
# and many prices are rounded to nice numbers:
qplot(priceadj, data = geo, geom="histogram", binwidth = 1e4, xlim = c(0, 2e6))

# On the log scale, distribution looks much nicer
qplot(log10(priceadj), data = geo, geom="histogram", binwidth = .1)
qplot(log10(priceadj), data = geo, geom="histogram", xlim=c(5, 6.5), binwidth = .02)

# Does this pattern change over time?
fp <- geom_freqpoly(aes(y = ..density..), binwidth = .05)
mid <- subset(geo, priceadj > 10^5 & priceadj < 10^6.5)

# 2008 looks like a particularly bad year
ggplot(mid, aes(log10(priceadj))) + fp + aes(colour = factor(year))
# No difference across months
ggplot(mid, aes(log10(priceadj))) + fp + aes(colour = factor(month))

# Pronounced flattening of distribution around Oct 07
ggplot(mid, aes(log10(priceadj))) + fp + facet_grid(year ~ month)


# Bin prices and look at number of sales -------------------------------------

day_sales <- ddply(mid, .(year, month), nrow)
qplot(year + (month - 1) / 12, V1, data = day_sales, geom = "line")
qplot(month, V1, data = day_sales, geom = "line", group = year)

breaks <- quantile(mid$priceadj, seq(0, 1, length = 11))
labels <- unname(breaks[-11] + breaks[-1]) / 2
mid$pricebin <- labels[as.numeric(cut(mid$priceadj, breaks = breaks))]

sales <- ddply(mid, .(year, month, pricebin), function(df) {
  data.frame(n = nrow(df), avg = mean(df$priceadj))
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
qplot(year + (month - 1) / 12, value, data = deciles, geom = "line", group=decile)  + geom_hline(yintercept = breaks[-c(1, 11)], colour="grey50")

# But most of the original pattern is a result of houses getting cheaper
# so more houses fall into the cheap bracket.

med <- rename(subset(deciles, decile == 5), c("value" = "median"))
med$decile <- NULL

# Relative to median house price, expensive houses have become more expensive
# and cheaper houses cheaper:  the variation in prices has increased as a 
# result of the housing crisis
deciles <- merge(deciles, med)
qplot(year + (month - 1) / 12, log10(value), data = deciles, geom = "line", group=decile)
qplot(year + (month - 1) / 12, log10(value / median), data = deciles, geom = "line", group=decile)

deciles <- deciles[order(deciles$year, deciles$month), ]
deciles <- ddply(deciles, .(decile), transform, index = value / value[1])
qplot(year + (month - 1) / 12, index, data = deciles, geom = "line", group=decile) + geom_hline(yintercept = 1, colour="grey50")
# It looks like the most expensive houses have been least affect.  The 
# cheapest houses have been most affected.

last_plot() + scale_y_log10()



# Bin prices into chunks of $100,000 -----------------------------------------

mid$pricebin <- round_any(mid$priceadj, 1e5, floor)
sales <- ddply(subset(mid, priceadj < 1e6), .(year, month, pricebin), 
  function(df) { data.frame(n = nrow(df), avg = mean(df$priceadj)) })
qplot(year + (month - 1) / 12, n, data = sales, geom = "line", xlab = "year") + facet_wrap(~ pricebin)

qplot(year + (month - 1) / 12, n, data = sales, geom = "line", xlab = "year", colour = factor(pricebin), size = I(2)) + scale_colour_brewer(pal = "Spectral", alpha=0.8)