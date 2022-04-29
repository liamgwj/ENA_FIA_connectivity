# LJ 2022-04-04
# read in raster stack of 110 FIA tree species, subset to known hosts, and
# assign suitability value to each cell

library(raster)

# raster stack of 110 tree species sumDBH(?) values
allstack <- stack(file.path("indata", "final_raster_stack",
                            "allspecies_stack_final.tif"))

# info on species in raster stack
trees <- read.csv(file.path("indata", "final_common_species_used.csv"))

# add latin binomial column
trees$latbi <- paste(trees$GENUS, trees$SPECIES, sep = " ")


# read in list of Amanita phalloides hosts from BC gov pamphlet
#hosts <- read.csv(file.path("indata", "BCgov_amanitaP-hosts.csv"))

#hostnames <- hosts$Host

# AP host genera from wolf and pringle
hostgen <- read.csv(file.path("indata", "WP2012_AmanitaP_hostGen.csv"))

hostgen <- hostgen$Host_Genus


# FIA species codes
hostcodes <- trees[which(trees$GENUS %in% hostgen), "SPCD"]
#hostcodes <- trees[which(trees$latbi %in% hostnames), "SPCD"]


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

#writeRaster(hostrasnorm,
#            file.path("output", "normalized_host_abundance"),
#            "ascii",
#            overwrite = TRUE)

# smaller testing subset
writeRaster(crop(hostrasnorm, extent(hostrasnorm, 200, 500, 200, 500)),
            file.path("output", "normalized_host_abundance"),
            "ascii",
            overwrite = TRUE)

