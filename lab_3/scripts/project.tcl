# Run with Vivado, or source from its Tcl Console. Paths follow this script.
set lab_dir [file normalize [file join [file dirname [info script]] ..]]
set decoder_top lab03_arif
set project_dir [file join $lab_dir build $decoder_top]
set project_file [file join $project_dir $decoder_top.xpr]
set part xc7a35tcpg236-1

if {[llength [get_parts -quiet $part]] == 0} {
    error "Missing $part device support. Install Vivado Artix-7 device support."
}
if {[llength [get_projects -quiet]] > 0} {
    set current_file [file normalize [file join [get_property DIRECTORY [current_project]] [get_property NAME [current_project]].xpr]]
    if {$current_file ne $project_file} {
        error "Close the current project before opening Lab 3."
    }
} elseif {[file exists $project_file]} {
    open_project $project_file
} else {
    create_project $decoder_top $project_dir -part $part
}
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property target_simulator XSim [current_project]
# Decoder-only lab: synthesis and simulation use the FPGA part without board pins.
# Source directories are authoritative, including additions and removals.
# add_files references tracked originals, so GUI edits are visible to Git.
foreach {fileset folder pattern} {sources_1 rtl *.v sim_1 sim *.v} {
    set old_files [get_files -quiet -of_objects [get_filesets $fileset]]
    set source_files [glob -nocomplain -directory [file join $lab_dir $folder] $pattern]
    if {![llength $source_files]} { error "No $pattern files in $folder" }
    foreach old_file $old_files {
        if {[lsearch -exact $source_files $old_file] < 0} {
            remove_files -fileset $fileset $old_file
        }
    }
    foreach source_file $source_files {
        if {[lsearch -exact $old_files $source_file] < 0} {
            add_files -norecurse -fileset $fileset $source_file
        }
    }
}
set_property top $decoder_top [get_filesets sources_1]
set_property top lab03_arif_tb [get_filesets sim_1]
set_property xsim.simulate.runtime 1600ns [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "INFO: Lab 3 ready: $project_file (Vivado [version -short])"
