# Default Lab 5 demo project opened by: ./lab open lab_5
# It contains both required testbenches; self_check_tb is the initial sim top.
set lab_dir [file normalize [file join [file dirname [info script]] ..]]
set project_name lab5
set project_dir [file join $lab_dir build $project_name]
set project_file [file join $project_dir $project_name.xpr]
set part xc7a35tcpg236-1

if {[llength [get_parts -quiet $part]] == 0} {
    error "Missing $part device support. Install Vivado Artix-7 device support."
}
if {[llength [get_projects -quiet]] > 0} {
    set current_file [file normalize [file join [get_property DIRECTORY [current_project]] [get_property NAME [current_project]].xpr]]
    if {$current_file ne $project_file} {
        error "Close the current project before opening the Lab 5 demo project."
    }
} elseif {[file exists $project_file]} {
    open_project $project_file
} else {
    create_project $project_name $project_dir -part $part
}

set_property target_language Verilog [current_project]
set_property target_simulator XSim [current_project]

set design_file [file join $lab_dir rtl cla4.v]
set self_check_file [file join $lab_dir sim self_check_tb.v]
set test_vector_file [file join $lab_dir sim test_vector_tb.v]
set vector_file [file join $lab_dir sim test_vector.tv]

if {[lsearch -exact [get_files -quiet -of_objects [get_filesets sources_1]] $design_file] < 0} {
    add_files -norecurse -fileset sources_1 $design_file
}
foreach simulation_file [list $self_check_file $test_vector_file $vector_file] {
    if {[lsearch -exact [get_files -quiet -of_objects [get_filesets sim_1]] $simulation_file] < 0} {
        add_files -norecurse -fileset sim_1 $simulation_file
    }
}
set_property file_type {Memory Initialization Files} [get_files $vector_file]

set_property top CLA4 [get_filesets sources_1]
set_property top self_check_tb [get_filesets sim_1]
set_property xsim.simulate.runtime 1us [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "INFO: Lab 5 demo project ready: $project_file"
puts "INFO: self_check_tb is the default simulation top. Set test_vector_tb as top to run Type 3."
