set lab_dir [file normalize [file join [file dirname [info script]] ..]]
file mkdir [file join $lab_dir build]
read_verilog [file join $lab_dir rtl cla4.v]
read_verilog [file join $lab_dir rtl alu32.v]
synth_design -top alu32 -part xc7a35tcpg236-1 -mode out_of_context
report_utilization -file [file join $lab_dir build utilization.txt]
write_checkpoint -force [file join $lab_dir build alu32.dcp]
