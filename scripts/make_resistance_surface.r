# LJ 2022-04-04 generate suitability surface given a list of host FIA codes

library(raster)
library(rnaturalearth)
library(sf)
library(terra)

# 'hostcodes', 'ID' must exist

# tree ranges ------------------------------------------------------------------

# load raster stack of 110 tree species sumDBH(?) values
allstack <- stack(file.path("indata", "final_raster_stack",
                            "allspecies_stack_final.tif"))

# assemble layer names from codes
hostlayers <- paste0("X", hostcodes)

# subset layers corresponding to hosts
hoststack <- subset(allstack, hostlayers, drop = FALSE)

# convert raster stack to array
hostarray <- as.array(hoststack)

# convert NA values to zeroes
hostarray <- ifelse(is.na(hostarray), 0, hostarray)

# sum cell values across species
hostmatrix <- apply(hostarray, MARGIN=c(1, 2), sum)

# normalize to max value
valMax <- max(hostmatrix)
hostmatnorm <- hostmatrix/valMax

# convert back to raster
hostrasnorm <- subset(hoststack, 1)
hostrasnorm[,] <- hostmatnorm


# human footprint --------------------------------------------------------------

## need to choose input layer carefully

# load raster
hfoot <- raster("indata/human_footprint/Maps/Built2009.tif")

# match crs
crs(hfoot) <- crs(hostrasnorm)@projargs

# crop to relevant extent
hfoot <- crop(hfoot, extent(hostrasnorm))

# change 10s to 1s
hfoot <- reclassify(hfoot, matrix(c(10,1), nrow=1))

# minor extent correction
extent(hfoot) <- extent(hostrasnorm)


# combine hosts and human footprint --------------------------------------------

hostrasnormHfoot <- overlay(hfoot, hostrasnorm, fun=function(x,y){y[x==1]<-0;y})

#plot(hostrasnormHfoot)

# write out --------------------------------------------------------------------

if(!dir.exists(file.path("output", ID))){
    dir.create(file.path("output", ID), recursive = TRUE)}

writeRaster(hostrasnormHfoot,
            file.path("output", ID, paste0(ID, "_suitability")),
            "ascii",
            overwrite = TRUE)

