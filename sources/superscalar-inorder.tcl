cd [file dirname [info script]]

# Add cache
source ../cache/sources.tcl
cd [file dirname [info script]]

# Add superscalar-inorder
source ../superscalar_inorder_dual/sources.tcl
cd [file dirname [info script]]

add_files ../cache/src/top/mycpu_top.sv