# Source inside an active XSim simulation with a decoder as the top module.
restart
# Initialize procedural blocks before applying the first forced input.
run 1 ns
set decoder_top [get_property top [get_filesets sim_1]]
set expected_values {40 79 24 30 19 12 02 78 00 10 08 03 46 21 06 0e}
add_force /$decoder_top/SW -radix hex {0 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 0]} { error "FAIL add_force SW=0: HEX0=$actual" }
puts "PASS add_force SW=0: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {1 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 1]} { error "FAIL add_force SW=1: HEX0=$actual" }
puts "PASS add_force SW=1: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {2 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 2]} { error "FAIL add_force SW=2: HEX0=$actual" }
puts "PASS add_force SW=2: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {3 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 3]} { error "FAIL add_force SW=3: HEX0=$actual" }
puts "PASS add_force SW=3: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {4 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 4]} { error "FAIL add_force SW=4: HEX0=$actual" }
puts "PASS add_force SW=4: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {5 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 5]} { error "FAIL add_force SW=5: HEX0=$actual" }
puts "PASS add_force SW=5: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {6 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 6]} { error "FAIL add_force SW=6: HEX0=$actual" }
puts "PASS add_force SW=6: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {7 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 7]} { error "FAIL add_force SW=7: HEX0=$actual" }
puts "PASS add_force SW=7: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {8 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 8]} { error "FAIL add_force SW=8: HEX0=$actual" }
puts "PASS add_force SW=8: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {9 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 9]} { error "FAIL add_force SW=9: HEX0=$actual" }
puts "PASS add_force SW=9: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {a 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 10]} { error "FAIL add_force SW=A: HEX0=$actual" }
puts "PASS add_force SW=A: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {b 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 11]} { error "FAIL add_force SW=B: HEX0=$actual" }
puts "PASS add_force SW=B: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {c 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 12]} { error "FAIL add_force SW=C: HEX0=$actual" }
puts "PASS add_force SW=C: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {d 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 13]} { error "FAIL add_force SW=D: HEX0=$actual" }
puts "PASS add_force SW=D: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {e 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 14]} { error "FAIL add_force SW=E: HEX0=$actual" }
puts "PASS add_force SW=E: HEX0=$actual"
add_force /$decoder_top/SW -radix hex {f 0ns}
run 100 ns
set actual [get_value -radix hex /$decoder_top/HEX0]
if {[string tolower $actual] ne [lindex $expected_values 15]} { error "FAIL add_force SW=F: HEX0=$actual" }
puts "PASS add_force SW=F: HEX0=$actual"
