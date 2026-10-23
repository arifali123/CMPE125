# Build the Basys 3 demo; invoke from lab_6/build.
source [file join [file dirname [info script]] project.tcl]
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    error "Board synthesis failed; see synth_1/runme.log."
}
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    error "Board implementation/bitstream failed; see impl_1/runme.log."
}
open_run impl_1
foreach port [get_ports] {
    if {[get_property PACKAGE_PIN $port] eq "" || [get_property IOSTANDARD $port] eq "DEFAULT"} {
        error "Missing pin or I/O standard for $port."
    }
}
report_timing_summary -file [file join $lab_dir build board_timing.txt]
report_utilization -file [file join $lab_dir build board_utilization.txt]
report_drc -file [file join $lab_dir build board_drc.txt]
foreach delay_type {max min} {
    set worst [get_timing_paths -delay_type $delay_type -max_paths 1]
    if {![llength $worst] || [get_property SLACK $worst] < 0} {
        error "Board timing failed ($delay_type); see board_timing.txt."
    }
}
puts "PASS: Basys 3 bitstream built; all ports assigned and internal setup/hold timing met."
puts "Program: [file join [get_property DIRECTORY [get_runs impl_1]] vending_machine_board.bit]"
close_project
