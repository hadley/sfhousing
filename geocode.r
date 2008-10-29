source("geocode-usc.r")

# Create empty addresses csv file if necessary.
if (!file.exists("addresses.csv")) {
  sales <- read.csv("house-sales.csv", stringsAsFactors = FALSE)
  addresses <- unique(sales[, c("street", "city", "zip")])
  addresses <- data.frame(addresses, "long" = NA, "lat" = NA, "quality" = NA_character_, "match" = NA_character_, "success" = NA_character_, "error" = NA_character_, stringsAsFactors = FALSE)
  write.table(addresses, "addresses.csv", sep=",", row=F)  
}

addresses <- read.csv("addresses.csv", stringsAsFactors = FALSE)
# Loop through a chunk at a time, saving results to csv as we go.
while(TRUE) {
  todo <- which(is.na(addresses$lat))[1:50]
  todo <- todo[!is.na(todo)]
  stopifnot(length(todo) > 0)
  loc <- do.call(geocode, addresses[todo, 1:3])
  stopifnot(ncol(loc) == 6)
  stopifnot(nrow(loc) == 50)

  addresses[todo, names(loc)] <- loc
  write.table(addresses, "addresses.csv", sep=",", row=F)
}

