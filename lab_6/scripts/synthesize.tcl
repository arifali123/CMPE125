# Optional synthesis-only check; invoke from lab_6/build.
# Use bitstream.tcl for the pin constraints, and full implementation.
set lab_dir [file normalize [file join [file dirname [info script]] ..]]
read_verilog [file join $lab_dir rtl vending_machine.v]
synth_design -top vending_machine -part xc7a35tcpg236-1
report_utilization -file [file join $lab_dir build utilization.txt]
write_checkpoint -force [file join $lab_dir build vending_machine.dcp]
