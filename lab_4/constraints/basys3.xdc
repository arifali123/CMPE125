# Basys 3 pins for CLA4. Switches: SW3:0 = A, SW7:4 = B, SW8 = Ci.
# LEDs: LED3:0 = S, LED4 = Co, LED5 = PG, LED6 = GG.

## SWITCHES

set_property PACKAGE_PIN V17 [get_ports {A[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[0]}]

set_property PACKAGE_PIN V16 [get_ports {A[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[1]}]

set_property PACKAGE_PIN W16 [get_ports {A[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[2]}]

set_property PACKAGE_PIN W17 [get_ports {A[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[3]}]

set_property PACKAGE_PIN W15 [get_ports {B[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[0]}]

set_property PACKAGE_PIN V15 [get_ports {B[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[1]}]

set_property PACKAGE_PIN W14 [get_ports {B[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[2]}]

set_property PACKAGE_PIN W13 [get_ports {B[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[3]}]

set_property PACKAGE_PIN V2 [get_ports {Ci}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ci}]

## LEDS

set_property PACKAGE_PIN U16 [get_ports {S[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S[0]}]

set_property PACKAGE_PIN E19 [get_ports {S[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S[1]}]

set_property PACKAGE_PIN U19 [get_ports {S[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S[2]}]

set_property PACKAGE_PIN V19 [get_ports {S[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S[3]}]

set_property PACKAGE_PIN W18 [get_ports {Co}]
set_property IOSTANDARD LVCMOS33 [get_ports {Co}]

set_property PACKAGE_PIN U15 [get_ports {PG}]
set_property IOSTANDARD LVCMOS33 [get_ports {PG}]

set_property PACKAGE_PIN U14 [get_ports {GG}]
set_property IOSTANDARD LVCMOS33 [get_ports {GG}]

# Basys 3 configuration voltage; this combinational circuit has no clock.
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
