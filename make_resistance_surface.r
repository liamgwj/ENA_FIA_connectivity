# LJ 2022-04-04

library(raster)

# raster stack of 110 tree species sumDBH(?) values
allstack <- stack(file.path("indata", "final_raster_stack",
                            "allspecies_stack_final.tif"))

# info on species in raster stack
trees <- read.csv(file.path("indata", "final_common_species_used.csv"))

# add latin binomial column
trees$latbi <- paste(trees$GENUS, trees$SPECIES)


# pest database
# Only 38 species shared between NA_Host and tree maps...
#pest_db <- read.csv(file.path("indata", "InsectxNAHost.csv"))
#
# choose a pest
#allpests <- unique(pest_db$Insect)
#
#pest_i <- allpests[1]
#
# identify hosts
#hostnames <- pest_db[which(pest_db$Insect == pest_i), "NA_Host"]

# for now, select some trees with maps to serve as "hosts"
hostnames <- c("Acer rubrum", sample(trees$latbi, 3))

# FIA species codes
hostcodes <- trees[which(trees$latbi %in% hostnames), "SPCD"]

# match orthography to raster stack layer names
hostlayers <- paste0("X", hostcodes)


# subset layers corresponding to hosts
hoststack <- subset(allstack, hostlayers, drop=FALSE)

# extract a reduced chunk for testing
#hoststack <- hoststack[500:1000, 500:1500, drop = FALSE]

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


# write out
if(!dir.exists("output")){dir.create("output")}

writeRaster(hostrasnorm,
            file.path("output", "normalized_host_abundance"),
            "ascii")

