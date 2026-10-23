# Basys 3 rev B: matches the vending-machine reference PDF's used pins.
# Pin reference: https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc
# Apply to vending_machine_board; the core vending_machine has no button port.

set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -name sys_clk_pin -period 10.000 [get_ports clk]

# SW0 = nickel, SW1 = dime, SW2 = quarter, SW3 = active-high reset.
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports Nickel]
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports Dime]
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports Quarter]
set_property -dict { PACKAGE_PIN W17 IOSTANDARD LVCMOS33 } [get_ports reset]

# Center pushbutton accepts the selected coin once per debounced press.
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports button]

# LED0 = two dimes, LED1 = dime, LED2 = nickel, LED3 = dispense.
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports ReturnTwoDimes]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports ReturnDime]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports ReturnNickel]
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports Dispense]

# Human controls have no clock relationship; each enters a synchronizer.
# Paths BETWEEN synchronizer stages and all internal logic remain timed.
set_false_path -from [get_ports {button Nickel Dime Quarter reset}]
# LEDs are static indicators with no external synchronous receiver.
set_false_path -to [get_ports {Dispense ReturnNickel ReturnDime ReturnTwoDimes}]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
