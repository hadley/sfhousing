library(plyr)
library(XML)

key <- "3073277cbeaf49fb8a74eebbcbede800"

geocode_url <- function(street, city, state = "CA", zip) {
  geo <- "http://webgis.usc.edu/Services/Geocode/GeocoderService.asmx/GeocodeAddressNonParsed?"
  
  params <- c(
    streetAddress = street,
    city = city,
    state = state,
    zip = zip,
    apiKey = key
  )
  
  p <- paste(names(params), "=", laply(params,URLencode), sep="", collapse ="&")
  paste(geo, p, sep="")
}


geocode <- function(street, city = "", state = "CA", zip = "") {
  paths <- unlist(mlply(cbind(street, city, state, zip), geocode_url))
  
  read <- function(path) {
    file <- try_default(download.file(path, "temp.xml", quiet = TRUE), 1)
    if (file == 1) return(",,,,,")

    xml <- suppressWarnings(xmlTreeParse("temp.xml", useInternalNodes = TRUE))
    file.remove("temp.xml")
    # Sys.sleep()
    xmlValue(xmlChildren(xmlChildren(xml)$WebServiceGeocodeResult)$AsString)
  }
  results <- llply(paths, read, .progress = "text")
  results <- llply(results, function(x) gsub(", ", ";", x))
  con <- textConnection(paste(unlist(results), collapse="\n"))
  df <- read.csv(con, header=F, stringsAsFactors = FALSE)
  close(con)

  names(df) <- c("long", "lat", "quality", "match", "success")# , "error")
  df
}

