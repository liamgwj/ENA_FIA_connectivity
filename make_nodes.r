# LJ 2022-04-05

library(raster)

# load suitability map
infile <- "normalized_host_abundance.asc"

map <- raster(file.path("output", infile))


map[,] <- 0

map[,1] <- 1

map[,ncol(map)] <- 2


if(!dir.exists("output")){dir.create("output")}

writeRaster(map,
            file.path("output", paste0("nodes_", infile)),
            "ascii")

