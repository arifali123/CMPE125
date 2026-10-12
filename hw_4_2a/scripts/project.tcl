# Open using ./lab open hw_4_2a, or source this script in Vivado.
set hw_dir [file normalize [file join [file dirname [info script]] ..]]
set project_dir [file join $hw_dir build hw_4_2a]
set project_file [file join $project_dir hw_4_2a.xpr]
if {[llength [get_projects -quiet]] > 0} {
    set current_file [file normalize [file join [get_property DIRECTORY [current_project]] [get_property NAME [current_project]].xpr]]
    if {$current_file ne $project_file} {
        error "Close the current project before opening hw_4_2a."
    }
} elseif {[file exists $project_file]} {
    open_project $project_file
} else {
    create_project hw_4_2a $project_dir -part xc7a35tcpg236-1
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
set_property top jk_from_d [get_filesets sources_1]
set_property used_in_simulation true [get_files -of_objects [get_filesets sim_1] */*_tb.v]
set_property top jk_from_d_tb [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sim_1
update_compile_order -fileset sources_1
puts "hw_4_2a ready. Run Behavioral Simulation to check jk_from_d."
