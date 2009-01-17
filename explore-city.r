library(ggplot2)
library(mgcv)
theme_set(theme_bw())
source("date.r")
source("explore-data.r")
source("map.r")


# Match up with census data ------------------------------------------

city <- read.csv("census-city.csv", stringsAsFactors = FALSE)
city_sales <- as.data.frame(table(geo$city))
names(city_sales) <- c("city", "sales")

missing <- merge(city, city_sales, by = "city", all = TRUE)
missing <- subset(missing, is.na(pop))[c("city","sales")]
subset(missing[order(-missing$sales), ], sales > 100)

# Select the biggest cities in terms of numbers of sales ---------------------
cities <- as.data.frame(table(geo$city))
names(cities) <- c("city", "freq")
big_cities <- subset(cities, freq > 2910) # 10 sales per week on avg

qplot(freq / 1000, reorder(city, freq), data = subset(big_cities, rank(-freq) < 20), ylab = NULL, xlab = "Number of sales (thousands)")
ggsave(file = "beautiful-data/graphics/big-cities.pdf", width = 4, height = 6)

# Only look at houses in big cities, reduces records to ~ 420,000
inbig <- subset(geo, city %in% big_cities$city)

# Summarise sales by day and city - 17,025 rows
if (file.exists("bigsum.rdata")) {
  load("bigsum.rdata") 
} else {
  bigsum <- ddply(inbig, .(city, date), function(df) {
    data.frame(
      n = nrow(df), 
      avg = mean(df$price, na.rm = T)
    ) 
  }, .progress = "text")
  save(bigsum, file = "bigsum.rdata")
}

qplot(date, n, data = bigsum, geom = "line", group = city, log="y")
qplot(date, avg, data = bigsum, geom = "line", group = city, log="y")
qplot(date, avg / 1e6, data = bigsum, geom = "line") + facet_wrap(~ city)

qplot(date, avg / 1e6, data = bigsum, geom = "line", colour = I(alpha("black", 1/3)), group = city, ylab="Average sale price (millions)", xlab=NULL)
ggsave(file = "beautiful-data/graphics/cities-price.pdf", width = 14, height = 4)



# Calculate city centres ---------------------------------------------------
centres <- ddply(geo, .(city), function(df) colwise(median)(df[c("lat", "long")]))

# Smoothing ------------------------------------------------------------------
sf <- subset(bigsum, city == "San Francisco")
qplot(date, avg, data = sf, geom = "line") + geom_smooth(method = "gam", formula = y ~ s(x))

# Smooth of log scale to reduce influence of outliers and then back-transform
# 
smooth <- function(df) {
  model <- gam(log(avg) ~ s(as.numeric(date)), data = df, na.action = na.exclude) 
  data.frame(date = df$date, value = exp(predict(model)))
}

smoothes <- ddply(bigsum, .(city), smooth)
bigsum2 <- merge(bigsum, smoothes, by = c("city", "date"))
ggplot(bigsum2, aes(date, group = city)) + 
  geom_line(aes(y = avg), colour = "grey50") +
  geom_line(aes(y = value)) + 
  scale_y_log10() + 
  facet_wrap(~ city) +
  opts(axis.text.x = theme_blank(), axis.text.y = theme_blank())

qplot(date, value / 1e6, data = bigsum2, geom = "line", colour = I(alpha("black", 1/2)), group = city, ylab="Average sale price (millions)", xlab=NULL)

ggsave(file = "beautiful-data/graphics/cities-smooth.pdf", width = 8, height = 4)


# Data manipulation ---------------------------------------------------------

# Index and convert to wide form
sum_std <- ddply(smoothes, .(city), transform, value = value / value[1])
sum_wide <- cast(sum_std, city ~ date)

# Produce some summary plots
qplot(date, value, data = sum_std, geom = "line", colour = I(alpha("black", 1/2)), group = city, ylab="Proportional change in price", xlab=NULL)
ggsave(file = "beautiful-data/graphics/cities-indexed.pdf", width = 8, height = 4)

ggplot(data = sum_std, aes(x = date, y = value)) +
  geom_hline(yintercept = 1, colour = "grey50") +
  geom_line() + 
  facet_wrap(~ city, ncol = 6) +
  scale_x_date(major = "2 years", minor = "year", format = "%y") +
  opts(strip.text.x = theme_text(size = 8)) + 
  labs(x = NULL, y = NULL)

ggsave(file = "beautiful-data/graphics/cities-individual.pdf", width = 8, height = 11.5)


# Simpler clustering ---------------------------------------------------------
# just look at peak and plummet

# Compute euclidean distance metrix on indexed values and 
# perform hierarchical clustering with Ward's distance
d <- dist(sum_wide[c("2006-02-05", "2008-11-09")])
clustering <- hclust(d, "ward")
# plot(clustering, labels = sum_wide$city)
df <- data.frame(
  city = sum_wide$city, 
  cl = factor(cutree(clustering, 3))
)
sum2 <- merge(sum_wide, df)

# The three clusters are rather arbitrary - you can imagine lots of 
# other ways to divide the points up, but these three groups do a reasonably
# good job
ggplot(sum2, aes(`2006-02-05`, `2008-11-09`)) +
  geom_hline(yintercept = 1, colour = "grey50") + 
  # geom_smooth(method = "lm", se = F) + 
  geom_point(aes(colour = cl, shape = cl)) +
  geom_text(aes(label = city), colour = alpha("black", 0.5), 
    size = 3, hjust = -0.05, angle = 45) + 
  geom_abline(colour = "grey50") + 
  coord_equal() +
  labs(x = "peak", y = "plummet")

ggsave(file = "beautiful-data/graphics/cities-clustering.pdf", width = 6, height = 6)

# There is a negative correlation between the peak and the plummet:
# the greater the peak, the greater the plummet.


# Show time series for each cluster
# Cluster 1: Not much of peak, not much of a drop
# Cluster 2: More of a peak, more of a drop
# Cluster 3: Big peak and big drop
sum_std2 <- merge(sum_std, df)
ggplot(sum_std2, aes(date, value)) +
  facet_grid(. ~ cl) + 
  geom_hline(yintercept = 1, colour = "grey50") + 
  geom_line(aes(group = city, colour = cl)) + 
  geom_smooth(size = 1, se = F, colour = "black")

ggsave(file = "beautiful-data/graphics/cities-indexed-clustered.pdf", width = 10, height = 4)

# Try and explain with covariates from the census data -----------------

city_sum <- sum2[c("city", "cl", "2006-02-05", "2008-11-09")]
names(city_sum)[3:4] <- c("peak", "plummet")

covar <- merge(city_sum, city, by = "city", all.x = TRUE)

# Compute and display drop from boom price
covar$price_drop <- with(covar, peak - plummet)

ggplot(covar, aes(price_drop, reorder(city, price_drop))) +
  geom_vline(xintercept = 0, colour="grey50") +
  geom_point() + 
  scale_y_discrete("Price drop", expand = c(0, 0.5)) + 
  ylab(NULL)
  
sum_std3 <- merge(sum_std, covar[c("city", "price_drop")])
sum_std3$dropr <- cut(sum_std3$price_drop, fullseq(range(sum_std3$price_drop), 0.2))

ggplot(sum_std3, aes(date, value)) +
  facet_wrap( ~ dropr) + 
  geom_hline(yintercept = 1, colour = "grey50") + 
  geom_line(aes(group = city)) + 
  scale_x_date(major = "years", minor = "6 months", format = "%y") + 
  labs(x = NULL, y = NULL)
ggsave(file = "beautiful-data/graphics/cities-indexed-grouped.pdf", width = 8, height = 5)



cor(covar[, c(4:35, 48)], use="pairwise")[,33]

# Most affected have:
#   * lower incomes
#   * fewer bachelors degrees
#   * more babies & children
#   * bigger households
#   * longer commutes
#   * fewer firms per capita
#   * more multiracial people
qplot(income, price_drop, data = covar)
ggsave(file = "beautiful-data/graphics/cities-income.pdf", width = 6, height = 6)
qplot(grads, price_drop, data = covar)
ggsave(file = "beautiful-data/graphics/cities-grads.pdf", width = 6, height = 6)
qplot(babies, price_drop, data = covar)
qplot(children, price_drop, data = covar)
qplot(housesold_size, price_drop, data = covar)
qplot(commute, price_drop, data = covar)
ggsave(file = "beautiful-data/graphics/cities-commute.pdf", width = 6, height = 6)
qplot(firms / pop, price_drop, data = covar)
qplot(multir, price_drop, data = covar)

# Geographic plot ----------------------------------------------------

covar <- merge(covar, centres)
ggplot(covar, aes(long, lat)) + 
  bayarea + 
  geom_point(aes(size = abs(price_drop), shape = factor(sign(price_drop))), 
    colour = alpha("black", 0.5)) + 
  scale_area("drop", breaks = c(0.1, 0.25, 0.5, 0.75), to = c(2, 6)) +
  scale_shape("direction") +
  coord_cartesian(
    xlim = expand_range(range(covar$long, na.rm = T), 0.2), 
    ylim = expand_range(range(covar$lat, na.rm = T), 0.2)
  ) +
  labs(x = NULL, y = NULL) + 
  scale_x_continuous(breaks = NA) +
  scale_y_continuous(breaks = NA)
ggsave(file = "beautiful-data/graphics/cities-geo-changes.pdf", width = 4, height = 4)

# Correlations --------------------------------------------------------------

i <- seq(2, 292, by = 5)
date_cor <- cor(sum_wide[, i])
colnames(date_cor) <- colnames(sum_wide[, i])
rownames(date_cor) <- colnames(sum_wide[, i])
date_cor[upper.tri(date_cor)] <- NA

corm <- melt(date_cor)
corm <- corm[complete.cases(corm), ]
names(corm) <- c("from", "to", "cor")
corm$from <- as.Date(corm$from)
corm$to <- as.Date(corm$to)

qplot(to, cor, data = corm, group = from, geom = "line", 
  colour = as.numeric(from)) + 
  scale_colour_gradient("", low="red", high = "blue", alpha=0.5) +
  geom_hline(yintercept = 0)
