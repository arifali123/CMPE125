source [file join [file dirname [info script]] project.tcl]
launch_simulation -simset sim_1 -mode behavioral
restart
add_wave /light/x1 /light/x2 /light/f
add_force /light/x1 {0 0ns} {1 50ns} -repeat_every 100ns
add_force /light/x2 {0 0ns} {1 100ns} -repeat_every 200ns
# Sample away from transitions; explicitly check all four truth-table rows.
run 25 ns
foreach {a b expected} {0 0 0 1 0 1 0 1 1 1 1 0} {
    set actual_a [get_value -radix bin /light/x1]
    set actual_b [get_value -radix bin /light/x2]
    set actual_f [get_value -radix bin /light/f]
    if {$actual_a ne $a || $actual_b ne $b || $actual_f ne $expected} {
        close_sim -force
        error "XOR mismatch: expected ($a,$b)->$expected; got ($actual_a,$actual_b)->$actual_f"
    }
    puts "PASS: ($a,$b) -> $actual_f"
    if {!($a == 1 && $b == 1)} { run 50 ns }
}
run 25 ns
close_sim -force
puts "PASS: All four XOR truth-table rows."
