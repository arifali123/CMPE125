source [file join [file dirname [info script]] project.tcl]
launch_simulation -mode behavioral
close_sim
set log_file [file join $project_dir ${project_name}.sim sim_1 behav xsim simulate.log]
set log_handle [open $log_file r]
set transcript [read $log_handle]
close $log_handle
if {![string match "*PASS: PDF board FSM:*" $transcript] || [regexp {Fatal:|FATAL:|ERROR|FAIL:} $transcript]} {
    error "vending_machine_tb failed; see $log_file."
}
close_project
