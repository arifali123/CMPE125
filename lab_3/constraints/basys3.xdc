## SWITCHES

set_property PACKAGE_PIN V17 [get_ports {SW[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[0]}]

set_property PACKAGE_PIN V16 [get_ports {SW[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[1]}]

set_property PACKAGE_PIN W16 [get_ports {SW[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[2]}]

set_property PACKAGE_PIN W17 [get_ports {SW[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[3]}]

## 7-SEGMENT DISPLAY

## HEX0[0] = a
## HEX0[1] = b
## HEX0[2] = c
## HEX0[3] = d
## HEX0[4] = e
## HEX0[5] = f
## HEX0[6] = g

set_property PACKAGE_PIN W7 [get_ports {HEX0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX0[0]}]

set_property PACKAGE_PIN W6 [get_ports {HEX0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX0[1]}]

set_property PACKAGE_PIN U8 [get_ports {HEX0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX0[2]}]

set_property PACKAGE_PIN V8 [get_ports {HEX0[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX0[3]}]

set_property PACKAGE_PIN U5 [get_ports {HEX0[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX0[4]}]

set_property PACKAGE_PIN V5 [get_ports {HEX0[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX0[5]}]

set_property PACKAGE_PIN U7 [get_ports {HEX0[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HEX0[6]}]

## DIGIT ENABLES

set_property PACKAGE_PIN U2 [get_ports {AN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[0]}]

set_property PACKAGE_PIN U4 [get_ports {AN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[1]}]

set_property PACKAGE_PIN V4 [get_ports {AN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[2]}]

set_property PACKAGE_PIN W4 [get_ports {AN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[3]}]

## CONFIGURATION VOLTAGE

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
