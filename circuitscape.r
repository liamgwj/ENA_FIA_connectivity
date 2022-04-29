# Circuitscape connectivity analysis
# LJ 2021-11-26 updated 2022-04-05

# input data format
# conductance surface:
# a raster with cell values equal to modelled suitability for the focal pest
# source/ground node file:
# a raster with the same extent as the conductance surface, with focal nodes located at uniform intervals around the perimeter of the map



# check for/create output directories
now <- gsub("[:-]", "", gsub(" ", "T", Sys.time()))

outdir <- file.path(getwd(), "output", paste0("circuitscape_", now))

if(!dir.exists(outdir)){dir.create(outdir, recursive = TRUE)}

outfile <- file.path(outdir, "out")


# copy input files to new 'circuitscape' directory and remove from 'output'
file.copy(c(file.path("output", "normalized_host_abundance.asc"),
            file.path("output", "nodes_normalized_host_abundance.asc")),
          c(file.path(outdir,  "normalized_host_abundance.asc"),
            file.path(outdir,  "nodes_normalized_host_abundance.asc")))

file.remove(c(file.path("output", "normalized_host_abundance.asc"),
              file.path("output", "nodes_normalized_host_abundance.asc")))


# create .ini file for circuitscape run ---------------------------------------

# specify suitability map file
suitmap <- file.path(outdir, "normalized_host_abundance.asc")

# specify node file
nodemap <- file.path(outdir, "nodes_normalized_host_abundance.asc")


# write .ini file
writeLines(
    c("[Circuitscape Mode]",
      "data_type = raster",
      "scenario = pairwise",
      
      "[Version]",
      "version = 5.0.0",
      
      "[Habitat raster or graph]",
      paste0("habitat_file = ", suitmap),
      "habitat_map_is_resistances = resistances",
      
      "[Connection Scheme for raster habitat data]",
      "connect_four_neighbors_only = false",
      "connect_using_avg_resistances = false",
      
      "[Short circuit regions (aka polygons)]",
      "use_polygons = false",
      "polygon_file = False",
      
      "[Options for advanced mode]",
      "ground_file_is_resistances = true",
      "source_file = (Browse for a current source file)",
      "remove_src_or_gnd = keepall",
      "ground_file = (Browse for a ground point file)",
      "use_unit_currents = false",
      "use_direct_grounds = false",
      
      "[Mask file]",
      "use_mask = false",
      "mask_file = None",
      
      "[Options for one-to-all and all-to-one modes]",
      "use_variable_source_strengths = false",
      "variable_source_file = None",
      
      "[Options for pairwise and one-to-all and all-to-one modes]",
      "included_pairs_file = (Browse for a file with pairs to include or exclude)",
      "use_included_pairs = false",
      paste0("point_file = ", nodemap),
      
      "[Calculation options]",
      "solver = cg+amg",
      
      "[Output options]",
      "write_cum_cur_map_only = true",
      "log_transform_maps = false",
      paste0("output_file = ", outfile),
      "write_max_cur_maps = false",
      "write_volt_maps = false",
      "set_null_currents_to_nodata = false",
      "set_null_voltages_to_nodata = false",
      "compress_grids = false",
      "write_cur_maps = true"
    ),
    con = file.path(outdir, "lastRun.ini"))


# run Circuitscape ------------------------------------------------------------

XRJulia::juliaUsing("Circuitscape")

XRJulia::juliaCommand(paste0("compute(\"",
                      file.path(outdir, "lastRun.ini"),
                      "\")"))

