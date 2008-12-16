library(plyr)

key <- "3073277cbeaf49fb8a74eebbcbede800"

geocode_url <- function(street, city, state = "CA", zip) {
  geo <- "http://webgis.usc.edu/Services/Geocode/GeocoderWebServiceHttpNonParsed.aspx?"
  
  params <- c(
    apiKey = key,
    streetAddress = street,
    city = city,
    state = state,
    zip = zip,
    format = "csv"
  )
  
  p <- paste(names(params), "=", laply(params,URLencode), sep="", collapse ="&")
  paste(geo, p, sep="")
}


geocode <- function(street, city = "", state = "CA", zip = "") {
  paths <- unlist(mlply(cbind(street, city, state, zip), geocode_url))
  
  results <- suppressWarnings(
    llply(paths, read.csv, header = FALSE, .progress = "text")
  )
  df <- do.call("rbind", results)

  names(df) <- c("id", "code", "success", "lat", "long", "quality", "match", "time")
  df
}

