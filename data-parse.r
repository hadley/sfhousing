library(plyr)
paths <- dir("data", pattern = "\\.txt$", full = T)


header <- function(path) {
  head <- readLines(path, 1) 
  head <- gsub("TABLE: homesold,", "", head)
  strsplit(head, ",")[[1]]
}

tidy_week <- function(path) {
  df <- readLines(path)[-(1:2)]
  head <- header(path)
  
  df <- gsub("[a-z]+: ", "", df)
  records <- (seq_along(df) - 1) %/% (length(head) + 1)
  # table(table(records)) 
  out <- do.call("rbind", tapply(df, records, c))
  colnames(out) <- c(head, "empty")
  out <- data.frame(out, stringsAsFactors = FALSE)
  
  out <- within(out, {
    price <- gsub("[$,]", "", price)
    date <- gsub("data/", "", gsub("\\.txt", "", path))
    zip <- as.numeric(zip)
    price <- as.numeric(price)
    br <- as.numeric(br)
    lsqft <- as.numeric(lsqft)
    bsqft <- as.numeric(bsqft)
    year <- as.numeric(year)
  })
  out$empty <- NULL
  out$newcity <- NULL
  out$rowid <- NULL
  
  out
}

one <- tidy_week(paths[1])

all <- llply(paths, tidy_week, .progress = "text")
df <- do.call("rbind.fill", all)

write.table(df, file = "house-sales.csv", quote=F, row=F, sep=",")