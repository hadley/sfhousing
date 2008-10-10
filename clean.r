library(ggplot2)
h <- read.csv("house-sales.csv", stringsAsFactors = FALSE)

h$br <- as.numeric(h$br)
h$year <- as.numeric(h$year)
h$price <- as.numeric(h$price)

source("geocode.r")

