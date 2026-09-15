# Run from any directory: vivado -mode batch -source /path/to/verify.tcl
set lab_dir [file normalize [file join [file dirname [info script]] ..]]
set scripts_dir [file join $lab_dir scripts]
set output_dir [file join $lab_dir build verification]
file mkdir $output_dir
cd $output_dir
create_project -force lab3_verification [file join $output_dir project] -part xc7a35tcpg236-1
set_property target_simulator XSim [current_project]
add_files [glob [file join $lab_dir rtl *.v]]
add_files -fileset sim_1 [glob [file join $lab_dir sim *.v]]
set_property top seven_segment_decoder [get_filesets sources_1]
set_property top seven_segment_decoder_tb [get_filesets sim_1]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
launch_simulation
run all
if {[get_value -radix dec /seven_segment_decoder_tb/i] != 16} {
    error "Testbench stopped before completing all 16 inputs"
}
close_sim
set decoder_top seven_segment_decoder
set_property top $decoder_top [get_filesets sources_1]
set_property top $decoder_top [get_filesets sim_1]
launch_simulation
source [file join $scripts_dir force_inputs.tcl]
close_sim
synth_design -rtl -top $decoder_top -part xc7a35tcpg236-1
close_design
synth_design -top $decoder_top -part xc7a35tcpg236-1
if {[llength [get_cells -quiet -hier -filter {REF_NAME =~ LD*}]]} {
    error "Unexpected latch in $decoder_top"
}
report_utilization -file [file join $output_dir ${decoder_top}_utilization.rpt]
write_checkpoint -force [file join $output_dir ${decoder_top}_synth.dcp]
close_design
puts "PASS: Lab 3 testbench, add_force sweep, elaboration, and synthesis completed."
