library(ggplot2)
# Inflation ------------------------------------------------------

cpi <- read.csv("cpi-west.csv")
cpi <- rbind(cpi, 
  data.frame(year = 2008, month = 11, cpi = cpi$cpi[nrow(cpi)]))
cpi$ratio <- cpi$cpi[nrow(cpi)] / cpi$cpi


qplot(year + month / 12, cpi / cpi[1], data = cpi, geom = "line", ylab = "Inflation") + xlab(NULL)
ggsave(file = "beautiful-data/graphics/daily-cpi.pdf", width = 8, height = 4)

