library(ggplot2)
source("date.r")
source("explore-data.r")

geo$year_sold <- year(geo$date) 
geo$year_sold[geo$year_sold < 1890 | geo$year_sold > 2008] <- NA
geo$year[geo$year < 1890 | geo$year > 2008] <- NA

qplot(year_sold - year, data = geo, binwidth = 1, ylab="age")

# Select all houses that were built close to the time that they were 
# sol
new <- subset(geo, year_sold - year <= 6)
new$age <- new$year_sold - new$year

qplot(date, price, data = new, log="y") + facet_wrap(~ age) + geom_smooth(se = F)