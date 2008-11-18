library(plyr)

from <- dir("data", rec = T, pattern = "\\.tbl$", full.name = TRUE)
to <- gsub("www.sfgate.com/c/a/", "", from)
to <- gsub("/", "-", to)
to <- gsub("-REHS.tbl", ".txt", to)
to <- gsub("data-", "data/", to)

mv <- paste("mv", from, to)

l_ply(mv, system)
system("rm -rf data/www.sfgate.com")