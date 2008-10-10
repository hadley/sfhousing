# Human readable url
# http://www.sfgate.com/cgi-bin/article.cgi?f=/c/a/2007/12/30/REHS_alameda.txt
# Machine readable url
# http://www.sfgate.com/c/a/2008/06/15/REHS.tb


# Get the data -----------------------
start <- as.Date("2003-04-27")
end <- as.Date("2008-10-05")

sundays <- as.POSIXlt(seq.Date(start, end, "week"))
base_url <- "http://www.sfgate.com/c/a"
suffix <- "REHS.tb"

pad <- function(x) sprintf("%02d", x)

url <- paste(
  base_url, 
  1900 + sundays$year, 
  pad(sundays$mon + 1), 
  pad(sundays$mday + 1), 
  suffix,
  sep="/")
  
  

geo <- "http://maps.google.com/maps/geo?q="
params <- "&output=xml&key=abcdefg


URLencode
1600+Amphitheatre+Parkway,+Mountain+View,+CA