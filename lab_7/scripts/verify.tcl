source [file join [file dirname [info script]] project.tcl]
foreach {top name} {alu32_tb alu32 basys_alu_tb basys_alu} {
    set_property top $top [get_filesets sim_1]
    update_compile_order -fileset sim_1
    launch_simulation -mode behavioral
    close_sim
    set log_file [file join $project_dir ${project_name}.sim sim_1 behav xsim simulate.log]
    set log_handle [open $log_file r]
    set transcript [read $log_handle]
    close $log_handle
    if {![string match "*PASS: $name all * tests passed.*" $transcript] || [regexp {Fatal:|FATAL:|ERROR|FAIL:} $transcript]} {
        error "$top failed; see $log_file."
    }
    file copy -force $log_file [file join $lab_dir build ${top}.log]
}
close_project
