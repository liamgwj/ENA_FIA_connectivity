# LJ 2022-04-05
# create node raster for circuitscape sources/grounds

library(raster)

# load suitability map
infile <- "normalized_host_abundance.asc"

map <- raster(file.path("output", infile))


# create empty node raster
nodes <- map
nodes[,] <- 0

# create nodes ---------------------------------

# specify spacing
spacing <- 40

# for a subset of rows, assign the first and last non-zero suitability cells in
# each row a unique numeric node ID

focalrows <- seq(from=1, to=nrow(map), by = spacing)

nfocalrows <- length(focalrows)

for(i in 1:nfocalrows){

row <- focalrows[i]

tmp <- which(map[row,]>0)

nodes[row, tmp[1]] <- i

nodes[row, tmp[length(tmp)]] <- nfocalrows + i

}


# repeat for columns

focalcols <- seq(from=1, to=ncol(map), by = spacing)

nfocalcols <- length(focalcols)

for(i in 1:nfocalcols){

col <- focalcols[i]

tmp <- which(map[,col]>0)

nodes[tmp[1], col] <- nfocalrows + i

nodes[tmp[length(tmp)], col] <- nfocalrows + nfocalcols + i

}


# write node map to file

writeRaster(nodes,
            file.path("output", paste0("nodes_", infile)),
            "ascii")

