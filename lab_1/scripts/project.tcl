# Run with Vivado, or source from its Tcl Console. Paths follow this script.
set lab_dir [file normalize [file join [file dirname [info script]] ..]]
set project_dir [file join $lab_dir build light]
set project_file [file join $project_dir light.xpr]
set part xc7a35tcpg236-1

if {[llength [get_parts -quiet $part]] == 0} {
    error "Missing $part device support. Install Vivado Artix-7 device support."
}
if {[llength [get_projects -quiet]] > 0} {
    set current_file [file normalize [file join [get_property DIRECTORY [current_project]] [get_property NAME [current_project]].xpr]]
    if {$current_file ne $project_file} {
        error "Close the current project before opening Lab 1."
    }
} elseif {[file exists $project_file]} {
    open_project $project_file
} else {
    create_project light $project_dir -part $part
}
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property target_simulator XSim [current_project]
# Board files are convenient, but the exact FPGA part and XDC suffice.
set boards [get_board_parts -quiet *basys3*]
if {[llength $boards] > 0} {
    set_property board_part [lindex [lsort -dictionary $boards] end] [current_project]
} else {
    puts "INFO: Basys 3 board files unavailable; using $part and explicit pin constraints."
}
# Source directories are authoritative, including additions and removals.
# add_files references tracked originals, so GUI edits are visible to Git.
foreach {fileset folder pattern} {sources_1 rtl *.v constrs_1 constraints *.xdc} {
    set old_files [get_files -quiet -of_objects [get_filesets $fileset]]
    if {[llength $old_files]} { remove_files -fileset $fileset $old_files }
    set source_files [glob -nocomplain -directory [file join $lab_dir $folder] $pattern]
    if {![llength $source_files]} { error "No $pattern files in $folder" }
    add_files -norecurse -fileset $fileset $source_files
}
set_property top light [get_filesets sources_1]
set_property top light [get_filesets sim_1]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "INFO: Lab 1 ready: $project_file (Vivado [version -short])"
