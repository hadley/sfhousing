city <- read.table("census-city.txt", sep = "|", stringsAsFactors = F, na = "X")

has_comma <- function(x) length(grep(",", x)) > 0
comma_cols <- sapply(city, has_comma)
strip_comma <- function(x) as.numeric(gsub(",", "", x))

city[comma_cols] <- lapply(city[comma_cols], strip_comma)
city$V3 <- as.numeric(city$V3)
city$V13 <- as.numeric(city$V13)

fields <- read.table("census-city.flds", sep = "|", stringsAsFactors = F)
names(city) <- fields$V2

write.table(city, "census-city.csv", sep=",", row=F)