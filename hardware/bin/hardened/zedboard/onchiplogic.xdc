# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# Constraints for Zynq 7020 - XC7Z020CLG484
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Clock Constraints
# ----------------------------------------------------------------------------
create_clock -period 10.000 -name clk [get_ports clk];

create_clock -period 20.000 -name bscan_tck_a [get_pins {BSCAN_A/TCK}]
create_clock -period 20.000 -name bscan_tck_b [get_pins {BSCAN_B/TCK}]
create_clock -period 20.000 -name bscan_tck_c [get_pins {BSCAN_C/TCK}]
create_clock -period 20.000 -name cfgclk [get_pins {STARTUP/CFGCLK}]

create_clock -period 20.000 -name bscan_tck_a_buf_0 [get_pins */bscan_a_buf_gen[0].lut_bscan_tck_a_buf/O]
create_clock -period 20.000 -name bscan_tck_a_buf_1 [get_pins */bscan_a_buf_gen[1].lut_bscan_tck_a_buf/O]
create_clock -period 20.000 -name bscan_tck_a_buf_2 [get_pins */bscan_a_buf_gen[2].lut_bscan_tck_a_buf/O]
create_clock -period 20.000 -name bscan_tck_b_buf_0 [get_pins */bscan_b_buf_gen[0].lut_bscan_tck_b_buf/O]
create_clock -period 20.000 -name bscan_tck_b_buf_1 [get_pins */bscan_b_buf_gen[1].lut_bscan_tck_b_buf/O]
create_clock -period 20.000 -name bscan_tck_b_buf_2 [get_pins */bscan_b_buf_gen[2].lut_bscan_tck_b_buf/O]
create_clock -period 20.000 -name cfgclk_buf_0 [get_pins */frame_ecc_buf_gen[0].lut_cfgclk_buf/O]
create_clock -period 20.000 -name cfgclk_buf_1 [get_pins */frame_ecc_buf_gen[1].lut_cfgclk_buf/O]
create_clock -period 20.000 -name cfgclk_buf_2 [get_pins */frame_ecc_buf_gen[2].lut_cfgclk_buf/O]

set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {bscan_tck_c}]
set_clock_groups -asynchronous -group [get_clocks {cfgclk}] -group [get_clocks {bscan_tck_a}]
set_clock_groups -asynchronous -group [get_clocks {cfgclk}] -group [get_clocks {bscan_tck_b}]
set_clock_groups -asynchronous -group [get_clocks {bscan_tck_a}] -group [get_clocks {cfgclk}]

# ----------------------------------------------------------------------------
# USER LOGIC PINS
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN U7 [get_ports {input}];
set_property IOSTANDARD LVCMOS33 [get_ports {input}];
set_property PACKAGE_PIN R7 [get_ports {output}];
set_property IOSTANDARD LVCMOS33 [get_ports {output}];
set_property PACKAGE_PIN Y9 [get_ports {clk}];
set_property IOSTANDARD LVCMOS33 [get_ports {clk}];

# ----------------------------------------------------------------------------
# Readback CRC logic configuration
# ----------------------------------------------------------------------------
set_property POST_CRC ENABLE [current_design]
set_property POST_CRC_ACTION CONTINUE [current_design]
set_property POST_CRC_FREQ {50} [current_design]
set_property POST_CRC_INIT_FLAG DISABLE [current_design]
set_property POST_CRC_SOURCE PRE_COMPUTED [current_design]

# ----------------------------------------------------------------------------
# ISOLATION AREAS
# ----------------------------------------------------------------------------
create_pblock pblock_user_logic_monitor_u
add_cells_to_pblock [get_pblocks pblock_user_logic_monitor_u] [get_cells -quiet [list user_logic_monitor_u]]
resize_pblock [get_pblocks pblock_user_logic_monitor_u] -add {SLICE_X64Y97:SLICE_X67Y98}

create_pblock pblock_fifo2bscan_voter_u
add_cells_to_pblock [get_pblocks pblock_fifo2bscan_voter_u] [get_cells -quiet [list fifo2bscan_voter_u]]
resize_pblock [get_pblocks pblock_fifo2bscan_voter_u] -add {SLICE_X110Y71:SLICE_X113Y88}

create_pblock pblock_fifo_engine_u0
add_cells_to_pblock [get_pblocks pblock_fifo_engine_u0] [get_cells -quiet [list fifo_engine_u0]]
resize_pblock [get_pblocks pblock_fifo_engine_u0] -add {SLICE_X100Y63:SLICE_X107Y70}
resize_pblock [get_pblocks pblock_fifo_engine_u0] -add {RAMB36_X5Y13:RAMB36_X5Y13}
resize_pblock [get_pblocks pblock_fifo_engine_u0] -add {RAMB18_X5Y26:RAMB18_X5Y27}
resize_pblock [get_pblocks pblock_fifo_engine_u0] -add {DSP48_X4Y26:DSP48_X4Y27}

create_pblock pblock_fifo_engine_u1
add_cells_to_pblock [get_pblocks pblock_fifo_engine_u1] [get_cells -quiet [list fifo_engine_u1]]
resize_pblock [get_pblocks pblock_fifo_engine_u1] -add {SLICE_X100Y79:SLICE_X107Y86}
resize_pblock [get_pblocks pblock_fifo_engine_u1] -add {RAMB36_X5Y16:RAMB36_X5Y16}
resize_pblock [get_pblocks pblock_fifo_engine_u1] -add {RAMB18_X5Y32:RAMB18_X5Y33}
resize_pblock [get_pblocks pblock_fifo_engine_u1] -add {DSP48_X4Y32:DSP48_X4Y33}

create_pblock pblock_fifo_engine_u2
add_cells_to_pblock [get_pblocks pblock_fifo_engine_u2] [get_cells -quiet [list fifo_engine_u2]]
resize_pblock [get_pblocks pblock_fifo_engine_u2] -add {SLICE_X100Y89:SLICE_X107Y96}
resize_pblock [get_pblocks pblock_fifo_engine_u2] -add {RAMB36_X5Y18:RAMB36_X5Y18}
resize_pblock [get_pblocks pblock_fifo_engine_u2] -add {RAMB18_X5Y36:RAMB18_X5Y37}
resize_pblock [get_pblocks pblock_fifo_engine_u2] -add {DSP48_X4Y36:DSP48_X4Y37}

create_pblock pblock_primitives_io_buf_u
add_cells_to_pblock [get_pblocks pblock_primitives_io_buf_u] [get_cells -quiet [list primitives_io_buf_u]]
resize_pblock [get_pblocks pblock_primitives_io_buf_u] -add {SLICE_X84Y63:SLICE_X95Y97}
resize_pblock [get_pblocks pblock_primitives_io_buf_u] -add {FRAME_ECC_X0Y0:FRAME_ECC_X0Y0}
resize_pblock [get_pblocks pblock_primitives_io_buf_u] -add {STARTUP_X0Y0:STARTUP_X0Y0}

set_property HD.ISOLATED true [get_cells fifo2bscan_voter_u]
set_property HD.ISOLATED true [get_cells fifo_engine_u0]
set_property HD.ISOLATED true [get_cells fifo_engine_u1]
set_property HD.ISOLATED true [get_cells fifo_engine_u2]
set_property HD.ISOLATED true [get_cells primitives_io_buf_u]

