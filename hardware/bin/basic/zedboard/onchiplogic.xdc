# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# Constraints for Zynq 7020 - XC7Z020CLG484
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Clock Constraints
# ----------------------------------------------------------------------------
create_clock -period 10.000 -name clk [get_ports clk];

create_clock -period 20.000 -name bscan_tck_c [get_pins {BSCAN_C/TCK}]

set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {bscan_tck_c}]

# ----------------------------------------------------------------------------
# USER LOGIC PINS
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN U7 [get_ports {input}];
set_property IOSTANDARD LVCMOS33 [get_ports {input}];
set_property PACKAGE_PIN R7 [get_ports {output}];
set_property IOSTANDARD LVCMOS33 [get_ports {output}];
set_property PACKAGE_PIN Y9 [get_ports {clk}];
set_property IOSTANDARD LVCMOS33 [get_ports {clk}];


