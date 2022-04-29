# LJ 2022-04-29 visualize circuitscape output

# now <- 

library(raster)
library(terra)


# read in current map
cur <- raster(file.path("output", 
                        paste0("circuitscape_", now),
                        "out_cum_curmap.asc"))

# read in suitability raster
suit <- raster(file.path("output", 
                        paste0("circuitscape_", now),
                        "normalized_host_abundance.asc"))
# testing: whole extent
suit <- hostrasnorm


# plot side by side
par(mfrow=c(1,2))
plot(suit); plot(cur)



# attempted to derive border polygon from suitability raster but 




bound <- suit
bound[,] <- 0

for(i in 1:nrow(suit)){

tmp <- which(suit[i,]>0)

bound[i, tmp[1]:tmp[length(tmp)]] <- 1

}


par(mfrow=c(1,2))
plot(suit); plot(bound)





# convert outer boundary of raster to polygon
pr <- as.polygons(rast(suit) > 0)







r <- suit > -Inf
# or alternatively
# r <- reclassify(x, cbind(-Inf, Inf, 1))

# convert to polygons (you need to have package 'rgeos' installed for this to work)
pp <- rasterToPolygons(r, dissolve=TRUE)

