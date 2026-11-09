source [file join [file dirname [info script]] project.tcl]
launch_simulation -mode behavioral
close_sim
# Require the self-checking testbench to reach its success message.
set sim_log [file join $project_dir hw_prefix_2.sim sim_1 behav xsim simulate.log]
set channel [open $sim_log r]
set sim_output [read $channel]
close $channel
if {![string match {*PASS: prefix_black 16/16 combinations; prefix16 404042 additions; intermediate prefix checks passed.*} $sim_output]} {
    error "Simulation did not complete all checks. See $sim_log"
}
synth_design -top prefix16 -part xc7a35tcpg236-1
if {[llength [get_cells -quiet -hierarchical -filter {REF_NAME =~ LD* || REF_NAME =~ FD*}]] != 0} {
    error "Unexpected storage in the combinational prefix adder"
}
report_utilization -file [file join $hw_dir build utilization.rpt]
puts "PASS: simulation and combinational synthesis."
close_project
