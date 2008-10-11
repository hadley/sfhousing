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
  out <- do.call("data.frame", tapply(df, records, c))
  colnames(out) <- c(head, "empty")
  
  out$price <- gsub("[$,]", "", out$price)
  out$date <- gsub("data/", "", path)
  out
}

one <- tidy_week(paths[1])

all <- llply(paths, tidy_week, .progress = "text")

# Need to make rbind.fill faster!
df <- do.call("rbind.fill", all)
save(df, file="all.rdata")

df <- df[, c("county", "city", "zip", "street", "price", "br", "lsqft" ,"bsqft","year" ,"datesold")]
df

write.table(df, file = "house-sales.csv", quote=F, row=F, sep=",")