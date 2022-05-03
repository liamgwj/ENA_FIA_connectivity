# LJ 2022-04-29 visualize circuitscape output

library(sf)
library(raster)
#library(terra)
library(rnaturalearth)
library(dplyr)


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





#Get USA
usa <- ne_states(country = "United States of America", returnclass = "sf")

#Study region states:

study.region.states <- c("Alabama", "Georgia", "Mississippi", "South Carolina",
                         "North Carolina", "Tennessee", "Kentucky", "Virginia",
                         "West Virginia", "Indiana", "Louisiana", "Arkansas",
                         "Missouri", "Illinois", "Ohio", "Pennsylvania",
                        "Maryland", "Indiana", "Iowa", "Delaware", "New Jersey")

### Study region

study.region <- usa %>% filter(name_nl %in% study.region.states)


#Now let's dissolve all but the outer boundary:

study.region.boundary <- st_union(study.region)


#Now reproject the layer to the same as the FIA raster layer:

fia.imputed.proj4string <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"

study.region.boundary.albers <- st_transform(study.region.boundary, fia.imputed.proj4string)


# and do original study region with states too
#study.region.albers <- st_transform(study.region, fia.imputed.proj4string)



#Simplify the border:
outer.border.simple <- rmapshaper::ms_simplify(study.region.boundary.albers, keep = 0.01, keep_shapes = FALSE)


#Based on recommendation that we use a buffer distance equal to 20% of the study area width, but we'll do 10% each side:

buffer.width <- 0.1*(st_bbox(study.region.boundary.albers)[3]-st_bbox(study.region.boundary.albers)[1])
buffer.width

### Create buffer

#OK, so let's create the buffer, using a negative distance

study.region.buffer <- st_buffer(study.region.boundary.albers, dist = -1*buffer.width)


ggplot() + 
  theme_bw() +
  geom_sf(data = study.region.boundary.albers, col = "grey", fill = NA, alpha = 0.4) + 
   geom_sf(data = study.region.buffer, fill = "red", alpha = 0.4)

#OK that looks good.

### Simplify boundary

#Simplify the border:

outer.border.simple <- rmapshaper::ms_simplify(study.region.boundary.albers, keep = 0.01, keep_shapes = FALSE)

#Have a look:
ggplot() + 
  theme_bw() +
 # geom_sf(data = study.region.boundary.albers, col = "blue", fill = NA, alpha = 0.4) + 
   geom_sf(data = study.region.buffer, fill = "red", alpha = 0.4) +
    geom_sf(data = outer.border.simple, col = "black", fill = NA, alpha = 0.4)








