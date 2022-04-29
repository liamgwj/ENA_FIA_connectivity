# LJ 2022-04-25 adapted from Jason's "ancillary_geospatial_data.Rmd"
# Preparing ancillary geospatial layers

#This script deals with importing the human footprint and other layers to be used in generating resistance surface maps.

library(terra)
library(sf)
library(tidyverse)
library(rnaturalearth)
library(raster)

#Create a raster with the same spatial attributes as the cropped FIA raster:

#Specifically: 

#class       : SpatRaster 
#dimensions  : 53294, 63030, 1  (nrow, ncol, nlyr)
#resolution  : 30, 30  (x, y)
#extent      : -51915, 1838985, 695835, 2294655  (xmin, xmax, ymin, ymax)
#coord. ref. : Albers_Conic_Equal_Area 
#source      : riley_imputedFIA_crop.tif 
#categories  : Count, tl_id, CN 
#name        :   Count 
#min value   :       1 
#max value   : 9296306 


study.region.raster.template <- terra::rast(
  nrow = 53294,
  ncol = 63030,
  resolution = 30,
  extent = c(-51915, 1838985, 695835, 2294655),
  crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs",
  xmin = -51915,
  ymin = 695835)

#Get USA, then filter out Hawaii and Alaska
usa <- rnaturalearth::ne_states(country = "United States of America", returnclass = "sf")
conus <- usa %>% filter(name != "Hawaii")
conus <- conus %>% filter(name != "Alaska")

#Study region states:

study.region.states <- c("Alabama", "Georgia", "Mississippi", "South Carolina", "North Carolina", "Tennessee", "Kentucky", 
                         "Virginia", "West Virginia", "Indiana", "Louisiana", "Arkansas", "Missouri", "Illinois", 
                         "Ohio", "Pennsylvania", "Maryland", "Indiana", "Iowa", 
                         "Delaware", "New Jersey")

### Study region

study.region <- conus %>% filter(name_nl %in% study.region.states)

#Make sure the map looks right
ggplot() + 
  theme_bw() +
   geom_sf(data = study.region, col = "grey", fill = NA, alpha = 0.4)

#Now let's dissolve all but the outer boundary:

study.region.boundary <- st_union(study.region)

ggplot() + 
  theme_bw() +
   geom_sf(data = study.region.boundary, col = "grey", fill = NA, alpha = 0.4)

#Now reproject the layer to the same as the FIA raster layer:

fia.imputed.proj4string <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"

study.region.boundary.albers <- st_transform(study.region.boundary, fia.imputed.proj4string)
# and do original study region with states too
study.region.albers <- st_transform(study.region, fia.imputed.proj4string)



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

## Import layers

### Human footprint data

#The human footprint data files were downloaded on Sunday December 5th, 2021 in a single ZIP file from Dryad (https://datadryad.org/stash/dataset/doi:10.5061/dryad.052q5).

#They are in the directory "./rawdata/human_footprint/Maps/", and the description of the layers is found in the "Data description.docx" file within the "./rawdata/human_footprint/Maps/" directory.

#It is 1km resolution, global extent.  

#The publication describing the datasets and methods is: https://doi.org/10.1038/ncomms12558

#Here's the code demonstrating for one of the datasets.

#### Example with categorical layer

#Import the "Built2009" GeoTIFF

built2009 <- terra::rast("./rawdata/human_footprint/Maps/Built2009.tif")
built2009

#All the HF layers are global extent, and are in "World_Mollweide" projection, centred on Greenwich.

#Note also it's a categorical raster, and we will  need to make the "Value" variable active

activeCat(built2009) <- 2

#, with "0" where non-built environments, and "1" in built environments.

hf.proj4 <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"


#Let's temporarily reproject the study region map to this, for clipping first

study.region.mollweide <- st_transform(outer.border.simple, hf.proj4)

#Now clip the raster layer:

built2009_study_region <- crop(built2009, study.region.mollweide)
activeCat(built2009_study_region) <- 2

#Now we need to create a new raster with 1km resolution and with same extent as study area.

#Calculate the number of rows and columns needed, using resolution of 1000m

x.extent <- extent(raster(study.region.raster.template))[2] - extent(raster(study.region.raster.template))[1]
y.extent <- extent(raster(study.region.raster.template))[4] - extent(raster(study.region.raster.template))[3]
# round to nearest km
study.region.1km.ncols <- round(x.extent/1000, 0)
study.region.1km.nrows <- round(y.extent/1000, 0)
study.region.xmin <- extent(raster(study.region.raster.template))[1]
study.region.ymin <- extent(raster(study.region.raster.template))[3]
# create spatial extent object:
study.region.1km.extent <- extent(raster(study.region.raster.template))
study.region.1km.extent[2] <- study.region.xmin+1000*study.region.1km.ncols
study.region.1km.extent[4] <- study.region.ymin+1000*study.region.1km.nrows

#Create the reference 1km raster for study region, which will be used for reprojecting/resampling.

study.region.1km.albers <- terra::rast(nrows = study.region.1km.nrows, ncols = study.region.1km.ncols,
                                       xmin = study.region.xmin, ymin = study.region.ymin,
                                       crs = fia.imputed.proj4string,
                                       extent = study.region.1km.extent,
                                       resolution = 1000)


#Reproject build environemnt layer to Albers, using nearest neighbour, because categorical.

built2009_study_region_albers <- terra::project(built2009_study_region, study.region.1km.albers, method = "near")

#Now we need to crop area outside of study region:

built2009_study_region_albers <- crop(built2009_study_region_albers, outer.border.simple)


#let's have a look (NOTE: there may be an error message that [can be ignored](https://github.com/rspatial/terra/issues/30)):

plot(built2009_study_region_albers)

#### Resistance values

#For this "build2009" layer, which is a categorical raster, we need to convert to a numeric raster, and replace the "1"s with whatever resistence value you want to use for build environment.

#Let's assume we will use 1000 as the value.

#We also need to replace true zero values (areas in the study region without built environment) with "1", because we'll be using raster calculations wherein values are multiplied, so "1" is needed wherever you don't want resistance changed.

#**NOTE** if instead you want to "SUM" the layers rather than multiply, then you need to keep the values as zero instead of changing to 1.

#First create new numeric raster:

built2009_study_region_albers.numeric <- terra::rast(
  nrows = nrow(built2009_study_region_albers), 
  ncols = ncol(built2009_study_region_albers),
  xmin = study.region.xmin, ymin = study.region.ymin,
  crs = fia.imputed.proj4string,
  extent = extent(raster(built2009_study_region_albers)),
  resolution = 1000,
  vals = 0)

#And mask the area outside study region (places "NA" values):  (here we use "mask" instead of "crop")

built2009_study_region_albers.numeric <- mask(built2009_study_region_albers.numeric, built2009_study_region_albers)

#Now put the value 1000 in locations where there are 1s in the categorical raster.

#First, let's count the number of cells that contain "10" (and we need to use the "na.omit" to get rid of NA values):

sum(na.omit(c(values(built2009_study_region_albers)[,]))==10)

#Now get the cell ID values where those 10s occur:

cell.ids <- terra::cells(built2009_study_region_albers, 10)
cell.zero.ids <- terra::cells(built2009_study_region_albers, 0)

#Confirm that there are the correct number of cell IDs:

length(cell.ids$Value) == sum(na.omit(c(values(built2009_study_region_albers)[,]))==10)

#Good!

#Now assign the resistance value of 1000 to the "10" locations in the new raster, and 1 where there are zeroes:

built2009_study_region_albers.numeric[cell.ids$Value] <- 1000
built2009_study_region_albers.numeric[cell.zero.ids$Value] <- 1

#Verify:

plot(built2009_study_region_albers.numeric)

#### Example with continuous numeric raster

#We'll use the pasture layer for this.  See description [here](https://doi.org/10.1038/ncomms12558).


pasture_2009 <- terra::rast("./rawdata/human_footprint/Maps/Pasture2009.tif")
pasture_2009

#**NOTE** apparently they're all categorical rasters, so that makes things easier.

#Crop to study region:

pasture_2009_study_region <- crop(pasture_2009, study.region.mollweide)

#Make "Value" the active layer
activeCat(pasture_2009_study_region) <- 2

#Reproject build environemnt layer to Albers, using nearest neighbour, because categorical.

pasture_2009_study_region_albers <- terra::project(pasture_2009_study_region, study.region.1km.albers, method = "near")

#Crop outside study area again:
pasture_2009_study_region_albers <- crop(pasture_2009_study_region_albers, outer.border.simple)

#Now create numeric raster:

pasture2009_study_region_albers.numeric <- terra::rast(
  nrows = nrow(pasture_2009_study_region_albers), 
  ncols = ncol(pasture_2009_study_region_albers),
  xmin = study.region.xmin, ymin = study.region.ymin,
  crs = fia.imputed.proj4string,
  extent = extent(raster(pasture_2009_study_region_albers)),
  resolution = 1000,
  vals = 0)


#Find cell IDs of locations of cell values to be replaced.

#In this layer, there are values 1 through 4 for pasture land, representing different amounts of pasture land in the give 1km pixel.
#I assume this is quartiles, so a "1" equals 25% or less, 2 is 25-50%, etc...

#So, let's assume we want to replace values 3 and 4 with a 10, and values 1 and 2 with a 5
cell.3_4.ids <- terra::cells(pasture_2009_study_region_albers, c(3, 4))
cell.1_2.ids <- terra::cells(pasture_2009_study_region_albers, c(1, 2))
cell.zero.ids <- terra::cells(pasture_2009_study_region_albers, 0)

#Now do the replacements
pasture2009_study_region_albers.numeric[cell.3_4.ids$Value] <- 10
pasture2009_study_region_albers.numeric[cell.1_2.ids$Value] <- 5
pasture2009_study_region_albers.numeric[cell.zero.ids$Value] <- 1

#Mask outside study area again:
pasture2009_study_region_albers.numeric <- mask(pasture2009_study_region_albers.numeric, pasture_2009_study_region_albers)

#Now plot
plot(pasture2009_study_region_albers.numeric)

## Raster calculations

#To do math on the rasters (e.g. multipling the resistence values together) see this [webpage](https://geocompr.robinlovelace.net/spatial-operations.html?q=alge#map-algebra).

#We have 2 numeric raster layers with resistance values, and say we want to multiply them:

built.times.pasture <- built2009_study_region_albers.numeric * pasture2009_study_region_albers.numeric

#Plot it:

plot(built.times.pasture)



