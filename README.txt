LJ 2022-05-13

scripts are run in order:

host_codes.r (interactive) -> make_resistance_surface.r -> make_nodes.r ->
cscape_ini.r

the latter three are sourced via source_scripts.r

the output files are then used to run circuitscape in Julia, and the
circuitscape outputs are fed into plotting.r (sourced)
