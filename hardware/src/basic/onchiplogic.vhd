---------------------------------- VHDL Code ----------------------------------
-- File         = onchiplogic.vhd
-- 
-- Purpose      = Top Level - Basic setup
-- 
-- Library      = work
-- 
-- Dependencies = none
-- 
-- Author       = University of Piraeus
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity onchiplogic is
  port
    (
    clk                      : in  std_logic;
    input                    : in  std_logic;
    output                   : out std_logic
    );
end onchiplogic;



architecture top of onchiplogic is


-------------------------------------------------------------------------------
-- USER LOGIC Components and Signals
-------------------------------------------------------------------------------
signal i_output              : std_logic;

component user_logic
  port 
    (
    clk                      : in  std_logic;
    input                    : in  std_logic;
    output                   : out std_logic
    );
end component;
-------------------------------------------------------------------------------
-- END OF USER LOGIC Components and Signals
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- USER LOGIC MONITORING Components and Signals
-------------------------------------------------------------------------------
signal bscan_tck_c           : std_logic;
signal bscan_tdo_c           : std_logic;
signal bscan_sel_c           : std_logic;
signal bscan_shift_c         : std_logic;
signal bscan_capture_c       : std_logic;
signal bscan_update_c        : std_logic;

component user_logic_monitoring
  port 
    (
    -- BSCAN Signals
    bscan_tck                : in  std_logic;
    bscan_sel                : in  std_logic;
    bscan_shift              : in  std_logic;
    bscan_capture            : in  std_logic;
    bscan_update             : in  std_logic;
    bscan_tdo                : out std_logic;
    -- User Logic Monitoring Signals
    clk                      : in  std_logic;
    output                   : in  std_logic
    );
end component;
-------------------------------------------------------------------------------
-- END OF USER LOGIC MONITORING Components and Signals
-------------------------------------------------------------------------------



begin

-------------------------------------------------------------------------------
-- USER LOGIC
-------------------------------------------------------------------------------
output                       <= i_output;

user_logic_u: user_logic
  port map
    (
    clk                      => clk,
    input                    => input,
    output                   => i_output
    );
-------------------------------------------------------------------------------
-- END OF USER LOGIC
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- USER LOGIC MONITORING (ACCESS THROUGH BSCAN)
-------------------------------------------------------------------------------
user_logic_monitor_u: user_logic_monitoring
  port map
    (
    -- BSCAN Signals
    bscan_tck                => bscan_tck_c,
    bscan_sel                => bscan_sel_c,
    bscan_shift              => bscan_shift_c,
    bscan_capture            => bscan_capture_c,
    bscan_update             => bscan_update_c,
    bscan_tdo                => bscan_tdo_c,
    -- User Logic Monitoring Signals
    clk                      => clk,
    output                   => i_output
    );

BSCAN_C: BSCANE2
  generic map 
    (
    JTAG_CHAIN     => 4                -- Value for USER command. Possible values: (1,2,3 or 4).
    )
  port map 
    (
    CAPTURE        => bscan_capture_c, -- 1-bit output: CAPTURE output from TAP controller.
    DRCK           => open,            -- 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or SHIFT are asserted.
    RESET          => open,            -- 1-bit output: Reset output for TAP controller.
    RUNTEST        => open,            -- 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
    SEL            => bscan_sel_c,     -- 1-bit output: USER active output.
    SHIFT          => bscan_shift_c,   -- 1-bit output: SHIFT output from TAP controller.
    TCK            => bscan_tck_c,     -- 1-bit output: Scan Clock output. Fabric connection to TAP Clock pin.
    TDI            => open,            -- 1-bit output: TDI output from TAP controller.
    TMS            => open,            -- 1-bit output: Test Mode Select input. Fabric connection to TAP.
    UPDATE         => bscan_update_c,  -- 1-bit output: UPDATE output from TAP controller
    TDO            => bscan_tdo_c      -- 1-bit input:  Data input for USER function.
    );
-------------------------------------------------------------------------------
-- END OF USER LOGIC MONITORING (ACCESS THROUGH BSCAN)
-------------------------------------------------------------------------------


end top;
