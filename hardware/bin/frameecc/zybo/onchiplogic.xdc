# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# Constraints for Zynq 7010 - XC7Z010CLG400
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Clock Constraints
# ----------------------------------------------------------------------------
create_clock -period 20.000 -name clk [get_ports clk];

create_clock -period 20.000 -name bscan_tck_a [get_pins {BSCAN_A/TCK}]
create_clock -period 20.000 -name bscan_tck_b [get_pins {BSCAN_B/TCK}]
create_clock -period 20.000 -name bscan_tck_c [get_pins {BSCAN_C/TCK}]
create_clock -period 20.000 -name cfgclk [get_pins {STARTUP/CFGCLK}]

set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {bscan_tck_c}]
set_clock_groups -asynchronous -group [get_clocks {cfgclk}] -group [get_clocks {bscan_tck_a}]
set_clock_groups -asynchronous -group [get_clocks {cfgclk}] -group [get_clocks {bscan_tck_b}]
set_clock_groups -asynchronous -group [get_clocks {bscan_tck_a}] -group [get_clocks {cfgclk}]

# ----------------------------------------------------------------------------
# USER LOGIC PINS
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN K17 [get_ports {input}]; 
set_property PACKAGE_PIN L17 [get_ports {output}]; 
set_property PACKAGE_PIN L16 [get_ports {clk}]; 

set_property IOSTANDARD LVCMOS33 [get_ports {input}]; 
set_property IOSTANDARD LVCMOS33 [get_ports {output}]; 
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]; 

# ----------------------------------------------------------------------------
# Readback CRC logic configuration
# ----------------------------------------------------------------------------
set_property POST_CRC ENABLE [current_design]
set_property POST_CRC_ACTION CONTINUE [current_design]
set_property POST_CRC_FREQ {50} [current_design]
set_property POST_CRC_INIT_FLAG DISABLE [current_design]
set_property POST_CRC_SOURCE PRE_COMPUTED [current_design]

