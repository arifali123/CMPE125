set lab_dir [file normalize [file join [file dirname [info script]] ..]]
set project_name lab_8
set project_dir [file join $lab_dir build $project_name]
set project_file [file join $project_dir $project_name.xpr]

if {[llength [get_projects -quiet]] > 0} {
    set current_file [file normalize [file join [get_property DIRECTORY [current_project]] [get_property NAME [current_project]].xpr]]
    if {$current_file ne $project_file} {
        error "Close the current project before opening Lab 8."
    }
} elseif {[file exists $project_file]} {
    open_project $project_file
} else {
    create_project $project_name $project_dir -part xc7a35tcpg236-1
}

set_property target_language Verilog [current_project]
set_property target_simulator XSim [current_project]
foreach {fileset folder pattern} {sources_1 rtl *.v sim_1 sim *.v} {
    set old_files [get_files -quiet -of_objects [get_filesets $fileset]]
    set source_files [glob -directory [file join $lab_dir $folder] $pattern]
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
set_property top ram_single [get_filesets sources_1]
set sim_fileset [get_filesets sim_1]
# Set the initial selection once, then preserve the user's enabled file.
if {[get_property top $sim_fileset] ne "lab8_tb"} {
    foreach testbench [get_files -of_objects $sim_fileset] {
        set_property is_enabled [expr {[file tail $testbench] eq "tb_ram_single.v"}] $testbench
    }
}
set_property top lab8_tb $sim_fileset
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property xsim.simulate.log_all_signals true [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "INFO: Lab 8 ready: $project_file"
