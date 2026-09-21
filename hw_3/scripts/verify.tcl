# Run from hw_3/build: vivado -mode batch -source ../scripts/verify.tcl
source [file join [file dirname [info script]] project.tcl]
foreach circuit {xor4 minority priority8 decoder2to4} {
    set_property top ${circuit}_tb [get_filesets sim_1]
    update_compile_order -fileset sim_1
    launch_simulation -mode behavioral
    close_sim
}
set_property top xor4_tb [get_filesets sim_1]
update_compile_order -fileset sim_1
close_project
