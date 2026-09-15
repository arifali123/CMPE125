# Basys 3: SW0 = x1, SW1 = x2, LED0 = f.
# Pin assignments: https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc
set_property PACKAGE_PIN V17 [get_ports x1]
set_property PACKAGE_PIN V16 [get_ports x2]
set_property PACKAGE_PIN U16 [get_ports f]
set_property IOSTANDARD LVCMOS33 [get_ports {x1 x2 f}]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
# This switch-driven combinational design has no clock.
