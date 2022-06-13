# LJ 2022-05-23 plot circuitscape current map


library(terra)
library(sf)
library(tidyverse)
library(rnaturalearth)
library(raster)
library(viridis)


## PREP: US states border map -------------------------------------------------

usa <- rnaturalearth::ne_states(country = "United States of America",
                                returnclass = "sf")

conus <- usa %>% filter(!name_nl %in% c("Alaska", "Hawaï"))

study.region.states <- c("Alabama", "Georgia", "Mississippi", "South Carolina",
                         "North Carolina", "Tennessee", "Kentucky", "Virginia",
                         "West Virginia", "Indiana", "Louisiana", "Arkansas",
                         "Missouri", "Illinois", "Ohio", "Pennsylvania",
                        "Maryland", "Indiana", "Iowa", "Delaware", "New Jersey")

study.region <- usa %>% filter(name_nl %in% study.region.states)

study.region.boundary <- st_union(study.region)

fia.imputed.proj4string <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"

study.region.boundary.albers <- st_transform(study.region.boundary,
                                             fia.imputed.proj4string)

study.region.albers <- st_transform(study.region, fia.imputed.proj4string)

outer.border.simple <- rmapshaper::ms_simplify(study.region.boundary.albers,
                                               keep = 0.01,
                                               keep_shapes = FALSE)

#Based on recommendation that we use a buffer distance equal to 20% of the study area width, but we'll do 10% each side:
buffer.width <- 0.1 * (st_bbox(study.region.boundary.albers)[3] -
                             st_bbox(study.region.boundary.albers)[1])

study.region.buffer <- st_buffer(study.region.boundary.albers,
                                 dist = -1 * buffer.width)

outer.border.simple <- rmapshaper::ms_simplify(study.region.boundary.albers,
                                               keep = 0.01,
                                               keep_shapes = FALSE)


# save plot -------------------------------------
#
#p_states <- ggplot() + 
#
#              geom_sf(data = conus,
#                      col = "black",
#                      fill = NA,
#                      alpha = 0.4) +
#
#              geom_sf(data = study.region.albers,
#                      col = "black",
#                      fill = "red",
#                      alpha = 0.4)
#
#
#ggsave(filename="states.png", plot=p_states,
#        width=1600, height=1600, units="px")
#


## current map -----------------------------------------------------------------

r <- terra::rast(paste0("output/", ID, "/out_", ID, "_cum_curmap.asc"))

crs(r) <- fia.imputed.proj4string

v1 <- vect(study.region.boundary.albers)

r2 <- terra::rasterize(v1, r, values=1, background=NA)
r3 <- terra::cover(r2, r, values = 1)
r4 <- log(r3 + 1)


#v2 <- vect(study.region.buffer)
#
#r5 <- terra::rasterize(v2, r4, values=1, background=NA)
#r6 <- terra::cover(r5, r, values = 1)


r7 <- raster(r4)




r_spdf <- as(r7, "SpatialPixelsDataFrame")
r_df <- as.data.frame(r_spdf)
colnames(r_df) <- c("value", "x", "y")


p_ID <- ggplot() +
            geom_raster(data = r_df,
                        aes(x = x, y = y, fill = value),
                        alpha = 0.8) +

            scale_fill_viridis(option="inferno", limits = c(0,5)) + 
            theme_bw() +
            coord_equal() +
            theme(axis.title.x=element_blank(),
                  axis.title.y=element_blank()) +

            geom_sf(data = study.region.buffer,
                    col = "red",
                    fill = NA,
                    alpha = 0.4,
                    size =0.5
                    ) #+

#geom_sf(data = study.region.boundary.albers,
#                      col = "black",
#                      fill = NA,
#                      alpha = 0.4)


ggsave(filename = paste0("output/", ID, "/", ID, "_curmap.png"), plot = p_ID,
        width=1600, height=1600, units="px")


# sutability map underlying the above -----------------------------------------

suit <- terra::rast(paste0("output/", ID, "/", ID, "_suitability.asc"))

crs(suit) <- fia.imputed.proj4string 
suit2 <- terra::rasterize(v1, suit, values=1, background=NA)
suit3 <- terra::cover(suit2, suit, values = 1)
suit4 <- log(suit3 + 1)

suit5 <- raster(suit4)

suit_spdf <- as(suit5, "SpatialPixelsDataFrame")
suit_df <- as.data.frame(suit_spdf)
colnames(suit_df) <- c("value", "x", "y")

suit_df$value[which(suit_df$value == 0)] <- NA

p_suit <- ggplot() +
        geom_raster(data=suit_df, aes(x=x, y=y, fill=value), alpha=0.8) +
        scale_fill_viridis(option="viridis", na.value = "grey60") + 
        theme_bw() +
        coord_equal() +
        theme(axis.title.x=element_blank(),
              axis.title.y=element_blank()) +

            geom_sf(data = study.region.buffer,
                    col = NA,
                    fill = NA,
                    alpha = 0.4,
                    size =0.5
                    )

ggsave(filename=paste0("output/", ID, "/", ID, "_suit.png"), plot=p_suit,
        width=1600, height=1600, units="px")

