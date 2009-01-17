library(ggplot2)
source("date.r")

# Inflation ------------------------------------------------------

cpi <- read.csv("finances-cpi-west.csv")
cpi <- rbind(cpi, 
  data.frame(year = 2008, month = 11, cpi = cpi$cpi[nrow(cpi)]))
cpi <- subset(cpi, (year == 2003 & month >= 4) | year > 2003)
cpi$ratio <- cpi$cpi / cpi$cpi[1]

qplot(year + month / 12, ratio, data = cpi, geom = "line", ylab = "Inflation") + xlab(NULL)
ggsave(file = "beautiful-data/graphics/daily-cpi.pdf", width = 8, height = 4)


# Interest rates -------------------------------------------------------------
# downloaded from http://research.stlouisfed.org/fred2/


mprime <- read.csv("finances-mprime.csv", stringsAsFactors = FALSE)
names(mprime) <- c("date", "mprime")
mprime$date <- as.Date(mprime$date)

fedfunds <- read.csv("finances-fedfunds.csv", stringsAsFactors = FALSE)
names(fedfunds) <- c("date", "fedfunds")
fedfunds$date <- as.Date(fedfunds$date)

irates <- subset(merge(mprime, fedfunds, by = "date"), date > as.Date("2003-03-01"))

qplot(mprime, fedfunds, data = irates)
with(irates, cor(mprime, fedfunds)) # 0.998 correlation

irates$month <- month(irates$date)
irates$year <- year(irates$date)

