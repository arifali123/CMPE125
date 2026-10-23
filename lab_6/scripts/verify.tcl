source [file join [file dirname [info script]] project.tcl]
try {
    foreach sim_top {vending_machine_tb vending_machine_board_tb} {
        set_property top $sim_top [get_filesets sim_1]
        if {$sim_top eq "vending_machine_board_tb"} {
            set_property is_enabled false [get_files [file join $lab_dir sim vending_machine.wcfg]]
            set_property is_enabled true [get_files [file join $lab_dir sim vending_machine_board.wcfg]]
            set_property xsim.view [file join $lab_dir sim vending_machine_board.wcfg] [get_filesets sim_1]
        }
        update_compile_order -fileset sim_1
        launch_simulation -mode behavioral
        close_sim
        set log_file [file join $project_dir ${project_name}.sim sim_1 behav xsim simulate.log]
        set log_handle [open $log_file r]
        set transcript [read $log_handle]
        close $log_handle
        if {![string match "*PASS:*" $transcript] || [regexp {Fatal:|FATAL:|ERROR|FAIL:} $transcript]} {
            error "$sim_top failed; see $log_file."
        }
    }
} finally {
    # Reopening the project always starts with the original FSM waveform demo.
    set_property top vending_machine_tb [get_filesets sim_1]
    set_property is_enabled true [get_files [file join $lab_dir sim vending_machine.wcfg]]
    set_property is_enabled false [get_files [file join $lab_dir sim vending_machine_board.wcfg]]
    set_property xsim.view [file join $lab_dir sim vending_machine.wcfg] [get_filesets sim_1]
    update_compile_order -fileset sim_1
}
close_project
