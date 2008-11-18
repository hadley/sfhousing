if (!exists("key")) message("You need to define a key variable containing the contents of your google maps API key")

geocode_url <- function(address) {
  geo <- "http://maps.google.com/maps/geo?"
  
  params <- c(
    key = key,
    q = address,
    output = "csv"
  )
  
  p <- paste(names(params), "=", laply(params,URLencode), sep="", collapse ="&")
  paste(geo, p, sep="")
}

geocode <- function(addresses) {
  paths <- laply(addresses, geocode_url)
  
  read <- function(path) {
    suppressWarnings(read.csv(url(path), header = FALSE))
  }
  df <- ldply(paths, read, .progress = "text")
  names(df) <- c("status", "accuracy", "lat", "long")
  df
}

addy <- function(row) {
  paste(row$street, ", ", row$city, " ", row$zip, sep="")
}

addresses <- read.csv("addresses.csv")

while(TRUE) {
  todo <- which(is.na(addresses$lat))[1:100]
  todo <- todo[!is.na(todo)]
  stopifnot(length(todo) > 0)
  loc <- geocode(addy(addresses[todo, ]))

  addresses[todo, names(loc)] <- loc
  write.table(addresses, "addresses.csv", sep=",", row=F)
}

addresses[!is.na(addresses$accuracy) & addresses$accuracy == 0, c("lat", "long")] <- NA

addresses[!is.na(addresses$lat) & addresses$lat < 30, c("lat", "long")] <- NA
qplot(long, lat, data=addresses)