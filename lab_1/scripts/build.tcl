source [file join [file dirname [info script]] project.tcl]
set target synth
if {[info exists argv] && [llength $argv]} { set target [lindex $argv 0] }
if {$target ni {synth bitstream}} { error "Expected synth or bitstream" }
set jobs 2
if {[info exists ::env(JOBS)]} { set jobs $::env(JOBS) }
if {![string is integer -strict $jobs] || $jobs < 1} { error "JOBS must be a positive integer" }
# Explicit rebuilds avoid using stale results after changing sources or machines.
reset_run synth_1
launch_runs synth_1 -jobs $jobs
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    error "Synthesis failed: [get_property STATUS [get_runs synth_1]]"
}
open_run synth_1
set report_dir [file join $lab_dir build reports]
file mkdir $report_dir
report_utilization -file [file join $report_dir utilization.rpt]
if {$target eq "bitstream"} {
    launch_runs impl_1 -to_step write_bitstream -jobs $jobs
    wait_on_run impl_1
    if {[get_property PROGRESS [get_runs impl_1]] ne "100%" ||
        ![file exists [file join $project_dir light.runs impl_1 light.bit]]} {
        error "Bitstream generation failed: [get_property STATUS [get_runs impl_1]]"
    }
    puts "INFO: Bitstream: [file join $project_dir light.runs impl_1 light.bit]"
}
