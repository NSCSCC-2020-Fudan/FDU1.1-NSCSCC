set script_name "scripts/recreate_prj.tcl"
set tmp_script_name [ string map { ".tcl" "_old.tcl" } ${script_name} ]
write_project_tcl -no_copy_sources -force -use_bd_files -origin_dir_override "scripts" -target_proj_dir "vivado" ${script_name}
file copy -force $script_name $tmp_script_name
set origfile [open $tmp_script_name r] 
set newfile  [open $script_name w+] 
while {[eof $origfile] != 1} { 
    gets $origfile lineInfo 
    if [ string equal $lineInfo "# Set 'sources_1' fileset file properties for local files"] {
    	puts $newfile "make_wrapper -files \[get_files *\${_xil_proj_name_}.bd\] -top -import"
    }
    if {! [string match "*file normalize *_wrapper.v*" $lineInfo]} {
    	puts $newfile $lineInfo
    } 
} 
close $origfile
close $newfile
file delete -force scripts/recreate_prj_old.tcl 

