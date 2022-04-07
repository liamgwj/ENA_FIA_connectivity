# LJ 2022-04-05

library(raster)

now <- "20220405T154433"

cur <- raster(file.path("output", 
                        paste0("circuitscape_", now),
                        "out_cum_curmap.asc"))

plot(cur)
