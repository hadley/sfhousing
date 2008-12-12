# Make map of region
library(maps)

rlong <- c(-124.5, -113.5)
rlat <- c(32.5, 42.5)



ca <- data.frame(map("state", xlim = rlong, ylim = rlat, plot = F)[c("x", "y")])
camap <- c(
  geom_path(aes(x, y), data = ca, colour=alpha("grey40", 0.5), size = 0.5),
  xlim(rlong),
  ylim(rlat)
)
