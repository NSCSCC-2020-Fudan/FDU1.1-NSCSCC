cd [file dirname [info script]]
source sources.tcl
add_files [glob src/synth/*.sv]
add_files [glob src/xsim/*.svh]
set_property is_global_include true [get_files src/xsim/global.svh]