# Open using ./lab open lab_6, or source this script in Vivado.
set lab_dir [file normalize [file join [file dirname [info script]] ..]]
set project_name lab6
set project_dir [file join $lab_dir build $project_name]
set project_file [file join $project_dir $project_name.xpr]
set part xc7a35tcpg236-1
if {[llength [get_parts -quiet $part]] == 0} {
    error "Missing $part device support. Install Vivado Artix-7 device support."
}
if {[llength [get_projects -quiet]] > 0} {
    set current_file [file normalize [file join [get_property DIRECTORY [current_project]] [get_property NAME [current_project]].xpr]]
    if {$current_file ne $project_file} {
        error "Close the current project before opening Lab 6."
    }
} elseif {[file exists $project_file]} {
    open_project $project_file
} else {
    create_project $project_name $project_dir -part $part
}
set_property target_language Verilog [current_project]
set_property target_simulator XSim [current_project]
foreach {fileset folder pattern} {sources_1 rtl *.v constrs_1 constraints *.xdc sim_1 sim *} {
    foreach source_file [glob -directory [file join $lab_dir $folder] $pattern] {
        if {![llength [get_files -quiet -of_objects [get_filesets $fileset] $source_file]]} {
            add_files -norecurse -fileset $fileset $source_file
        }
    }
}
set_property file_type {Memory Initialization Files} [get_files [file join $lab_dir sim test_vector.tv]]
# The default simulation now demonstrates the same PDF design used on the board.
set_property is_enabled false [get_files [file join $lab_dir sim vending_machine.wcfg]]
set_property is_enabled true [get_files [file join $lab_dir sim vending_machine_board.wcfg]]
set_property top vending_machine_board [get_filesets sources_1]
set_property top vending_machine_board_tb [get_filesets sim_1]
set_property xsim.view [file join $lab_dir sim vending_machine_board.wcfg] [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "Lab 6 ready: simulate vending_machine_board_tb (PDF FSM), then generate the vending_machine_board bitstream."
