# Inputs: A = SW0, B = SW1, Cin = SW2 (classroom pin assignments).
set_property PACKAGE_PIN V17 [get_ports A]
set_property IOSTANDARD LVCMOS33 [get_ports A]
set_property PACKAGE_PIN V16 [get_ports B]
set_property IOSTANDARD LVCMOS33 [get_ports B]
set_property PACKAGE_PIN W16 [get_ports Cin]
set_property IOSTANDARD LVCMOS33 [get_ports Cin]

# Outputs: S = LED0, Cout = LED1.
set_property PACKAGE_PIN U16 [get_ports S]
set_property IOSTANDARD LVCMOS33 [get_ports S]
set_property PACKAGE_PIN E19 [get_ports Cout]
set_property IOSTANDARD LVCMOS33 [get_ports Cout]

# Basys 3 configuration voltage; this combinational circuit has no clock.
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
