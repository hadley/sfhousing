source("geocode-usc.r")

if (!file.exists("addresses.csv")) {
  # Create empty addresses csv file if necessary.
  # This is only needed if we start from scratch
  sales <- read.csv("house-sales.csv", stringsAsFactors = FALSE)
  addresses <- unique(sales[, c("street", "city", "zip")])
  addresses <- data.frame(addresses, "long" = NA, "lat" = NA, "quality" = NA_character_, "match" = NA_character_, "success" = NA_character_, "error" = NA_character_, stringsAsFactors = FALSE)
  write.table(addresses, "addresses.csv", sep=",", row=F)  
} else {
  # Update addresses with new rows from house-sales

  message("Loading existing data...")
  sales <- read.csv("house-sales.csv", stringsAsFactors = FALSE)
  ad  <- read.csv("addresses.csv", stringsAsFactors = FALSE)

  message("Merging...")
  geo <- merge(sales, ad, by = c("street", "city", "zip"), all.x = T)
  new <- subset(geo, is.na(quality))
  new_ad <- unique(new[, c("street", "city", "zip")])

  library(plyr)
  message("Adding new addresses and saving to disk...")
  ad <- unique(rbind.fill(ad, new_ad))

  write.table(ad, "addresses.csv", sep=",", row=F)  
}

addresses <- read.csv("addresses.csv", stringsAsFactors = FALSE)
# Loop through a chunk at a time, saving results to csv as we go.
while(TRUE) {
  todo <- which(is.na(addresses$quality))[1:50]
  todo <- todo[!is.na(todo)]
  stopifnot(length(todo) > 0)
  loc <- do.call(geocode, addresses[todo, 1:3])
  stopifnot(ncol(loc) == 8)
  stopifnot(nrow(loc) == 50)

  vars <- intersect(names(loc), names(addresses))
  addresses[todo, vars] <- loc[vars]
  write.table(addresses, "addresses.csv", sep=",", row=F)
}

