# LJ 2021-11-26 write ini file for circuitscape run

# specify suitability map file
suitmap <- paste0("/home/liamgwj/circuitscape/", ID, "/", ID, "_suitability.asc")

# specify node file
nodemap <- paste0("/home/liamgwj/circuitscape/", ID, "/nodes_", ID, "_suitability.asc")


outfile <- paste0("/scratch/st-jpither-1/liamgwj/out_", ID)


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
    con = file.path("output", paste0(ID, ".ini"))
)


