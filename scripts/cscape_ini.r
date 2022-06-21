# LJ 2021-11-26 create files needed to run circuitscape


# julia script to run circuitscape ---------------------------------------------

writeLines(c("using Circuitscape",
             paste0("compute(\"/scratch/st-jpither-1/liamgwj/",
                    ID, "/", ID, ".ini\")")),
           con = file.path("output", ID, paste0(ID, "_cscape.jl"))
)


# .ini file fed to circuitscape call -------------------------------------------

# specify suitability map file
suitmap <- paste0("/scratch/st-jpither-1/liamgwj/", ID, "/", ID, "_suitability.asc")

# specify node file
nodemap <- paste0("/scratch/st-jpither-1/liamgwj/", ID, "/nodes_", ID, "_suitability.asc")

# specify output file
outfile <- paste0("/scratch/st-jpither-1/liamgwj/", ID, "/out_", ID)


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
    con = file.path("output", ID, paste0(ID, ".ini"))
)


# pbs script to submit job to cluster ------------------------------------------

writeLines(c("#!/bin/bash",
             "# ------------Sockeye Parameters----------------- #",
             "#PBS -l walltime=05:00:00,select=1:ncpus=24:mem=100gb",
             paste0("#PBS -N ", ID, "_cscape"),
             "#PBS -A st-jpither-1",
             "#PBS -m abe",
             "#PBS -M liam.johnson@ubc.ca",
             paste0("#PBS -o ", ID, "_output.txt"),
             paste0("#PBS -e ", ID, "_error.txt"),
             "# ----------------Modules------------------------- #",
             "module load Software_Collection/2021",
             "module load gcc/9.4.0 intel-mkl/2020.4.304 julia/1.6.1",
             "# -----------------My Commands-------------------- #",
             paste0("julia /scratch/st-jpither-1/liamgwj/",
                    ID, "/", ID, "_cscape.jl")),
           con = file.path("output", ID, paste0(ID, "_cscape.pbs")))


# bash commands to connect to cluster, move files and queue pbs script ---------

writeLines(c(paste0("scp -r /home/liam/Documents/MSc/analysis/ENA_FIA_connectivity/output/", ID, " liamgwj@dtn.sockeye.arc.ubc.ca:/scratch/st-jpither-1/liamgwj"),
             "ssh liamgwj@sockeye.arc.ubc.ca",
             paste0("cd /scratch/st-jpither-1/liamgwj/", ID),
             paste0("qsub ", ID, "_cscape.pbs")),
           con = file.path("output", ID, paste0(ID, "_bash.txt")))


