library(ggplot2)
source("date.r")
source("explore-data.r")

# Can we find houses that have been repeatedly bought and sold?

geo$ad <- paste(geo$street, geo$city, geo$zip)
dups <- tapply(seq_len(nrow(geo)), geo$ad , length)
table(dups)

# There are a total of 68,167 addresses that have been sold more than
# once, for a total of 441,546 sales.
dup_ads <- names(dups)[dups > 1]
multi <- geo[geo$ad %in% dup_ads, ]


# Seems like we should be able to use this to better model the changing
# prices.  But how?  Mixed effects model?

