# Control for inflation ------------------------------------------------------

cpi <- read.csv("cpi-west.csv")
cpi <- rbind(cpi, 
  data.frame(year = 2008, month = 11, cpi = cpi$cpi[nrow(cpi)]))
cpi$ratio <- cpi$cpi[nrow(cpi)] / cpi$cpi

geo$month <- month(geo$date)
geo$year <- year(geo$date)

geo <- merge(geo, cpi, by = c("month", "year"), sort = F)
geo$priceadj <- geo$price * geo$ratio
