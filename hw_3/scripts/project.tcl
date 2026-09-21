# Open using ./lab open hw_3, or source this script in Vivado.
set hw_dir [file normalize [file join [file dirname [info script]] ..]]
set project_dir [file join $hw_dir build hw_3]
set project_file [file join $project_dir hw_3.xpr]
if {[llength [get_projects -quiet]] > 0} {
    set current_file [file normalize [file join [get_property DIRECTORY [current_project]] [get_property NAME [current_project]].xpr]]
    if {$current_file ne $project_file} {
        error "Close the current project before opening HW 3."
    }
} elseif {[file exists $project_file]} {
    open_project $project_file
} else {
    create_project hw_3 $project_dir -part xc7a35tcpg236-1
}
set_property target_language Verilog [current_project]
set_property target_simulator XSim [current_project]
foreach {fileset folder} {sources_1 rtl sim_1 sim} {
    foreach source_file [glob -directory [file join $hw_dir $folder] *.v] {
        if {![llength [get_files -quiet -of_objects [get_filesets $fileset] $source_file]]} {
            add_files -norecurse -fileset $fileset $source_file
        }
    }
}
set_property top xor4 [get_filesets sources_1]
set_property used_in_simulation true [get_files -of_objects [get_filesets sim_1] */*_tb.v]
set_property top xor4_tb [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sim_1
update_compile_order -fileset sources_1
puts "HW 3 ready. Set the desired testbench as Top in Simulation Sources."
