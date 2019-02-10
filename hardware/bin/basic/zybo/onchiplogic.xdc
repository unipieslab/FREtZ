# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# Constraints for Zynq 7010 - XC7Z010CLG400
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Clock Constraints
# ----------------------------------------------------------------------------
create_clock -period 20.000 -name clk [get_ports clk];

create_clock -period 20.000 -name bscan_tck_c [get_pins {BSCAN_C/TCK}]

set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {bscan_tck_c}]

# ----------------------------------------------------------------------------
# USER LOGIC PINS
# ---------------------------------------------------------------------------- 


set_property PACKAGE_PIN K17 [get_ports {input}]; 
set_property PACKAGE_PIN L17 [get_ports {output}]; 
set_property PACKAGE_PIN L16 [get_ports {clk}]; 

set_property IOSTANDARD LVCMOS33 [get_ports {input}]; 
set_property IOSTANDARD LVCMOS33 [get_ports {output}]; 
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]; 


