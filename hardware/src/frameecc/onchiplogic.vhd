---------------------------------- VHDL Code ----------------------------------
-- File         = onchiplogic.vhd
-- 
-- Purpose      = Top Level - FRAME ECC based setup
-- 
-- Library      = work
-- 
-- Dependencies = none
-- 
-- Author       = University of Piraeus
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.tmr_types_pkg.all;

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


-------------------------------------------------------------------------------
-- INTERNAL SCRUBBER Components and Signals
-------------------------------------------------------------------------------
component fifo_engine
  port 
    (
    -- BSCAN A Signals
    bscan_tck_a              : in  std_logic;
    bscan_tdi_a              : in  std_logic;
    bscan_sel_a              : in  std_logic;
    bscan_shift_a            : in  std_logic;
    bscan_capture_a          : in  std_logic;
    bscan_update_a           : in  std_logic;
    bscan_tdo_a              : out std_logic;
    -- BSCAN B Signals
    bscan_tck_b              : in  std_logic;
    bscan_sel_b              : in  std_logic;
    bscan_capture_b          : in  std_logic;
    bscan_update_b           : in  std_logic;
    bscan_tdo_b              : out std_logic;
    -- FRAME ECC Signals
    cfgclk                   : in  std_logic;
    crc_error                : in  std_logic;
    ecc_error                : in  std_logic;
    syndrome_valid           : in  std_logic;
    syndrome                 : in  std_logic_vector(12 downto 0);
    frame_address            : in  std_logic_vector(25 downto 0);
    single_ecc_error         : in  std_logic;
    syn_bit                  : in  std_logic_vector(4 downto 0);
    syn_word                 : in  std_logic_vector(6 downto 0)    
   );
end component;


-- BSCAN Signals
signal bscan_tck_a           : std_logic;
signal bscan_tdi_a           : std_logic;
signal bscan_tdo_a           : std_logic;
signal bscan_sel_a           : std_logic;
signal bscan_shift_a         : std_logic;
signal bscan_capture_a       : std_logic;
signal bscan_update_a        : std_logic;

signal bscan_tck_b           : std_logic;
signal bscan_tdo_b           : std_logic;
signal bscan_sel_b           : std_logic;
signal bscan_capture_b       : std_logic;
signal bscan_update_b        : std_logic;

-- FRAME ECC Signals
signal cfgclk                : std_logic;
signal crc_error             : std_logic;
signal ecc_error             : std_logic;
signal frame_address         : std_logic_vector(25 downto 0);
signal syndrome_valid        : std_logic;
signal syndrome              : std_logic_vector(12 downto 0);
-------------------------------------------------------------------------------
-- END OF INTERNAL SCRUBBER Components and Signals
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


-------------------------------------------------------------------------------
-- INTERNAL SCRUBBING LOGIC
-------------------------------------------------------------------------------
fifo_engine_u: fifo_engine
  port map
    (
    -- BSCAN A Signals
    bscan_tck_a              => bscan_tck_a,
    bscan_tdi_a              => bscan_tdi_a,
    bscan_sel_a              => bscan_sel_a,
    bscan_shift_a            => bscan_shift_a,
    bscan_capture_a          => bscan_capture_a,
    bscan_update_a           => bscan_update_a,
    bscan_tdo_a              => bscan_tdo_a,
    -- BSCAN B Signals
    bscan_tck_b              => bscan_tck_b,
    bscan_sel_b              => bscan_sel_b,
    bscan_capture_b          => bscan_capture_b,
    bscan_update_b           => bscan_update_b,
    bscan_tdo_b              => bscan_tdo_b,
    -- FRAME ECC Signals
    cfgclk                   => cfgclk,
    crc_error                => crc_error,
    ecc_error                => ecc_error,
    syndrome_valid           => syndrome_valid,
    syndrome                 => syndrome,
    frame_address            => frame_address,
    single_ecc_error         => '0', 
    syn_bit                  => (others => '0'),
    syn_word                 => (others => '0')
    );


FRAME_ECC: FRAME_ECCE2
  generic map 
    (
    FARSRC                   => "FAR",  -- Determines if the output of FAR[25:0] configuration register points to the FAR or EFAR. 
                                        -- Sets configuration option register bit CTL0[7].
    FRAME_RBT_IN_FILENAME    => "NONE"  -- This file is output by the ICAP_E2 model and it contains Frame Data
                                        -- information for the Raw Bitstream (RBT) file. The FRAME_ECCE2 model
                                        -- will parse this file, calculate ECC and output any error conditions.
    )
  port map 
    (
    CRCERROR                 => crc_error,        -- 1-bit output: Output indicating a CRC error.
    ECCERROR                 => ecc_error,        -- 1-bit output: Output indicating an ECC error.
    FAR                      => frame_address,    -- 26-bit output: Frame Address Register Value output.
    SYNDROME                 => syndrome,         -- 13-bit output: Output location of erroneous bit.
    SYNDROMEVALID            => syndrome_valid,   -- 1-bit output: Frame ECC output indicating the SYNDROME output is valid.
    ECCERRORSINGLE           => open,             -- 1-bit output: Output Indicating single-bit Frame ECC error detected.
    SYNBIT                   => open,             -- 5-bit output: Output bit address of error.
    SYNWORD                  => open              -- 7-bit output: Word output in the frame where an ECC error has been detected.
    );


STARTUP: STARTUPE2
  generic map
    (
    PROG_USR       => "FALSE",
    SIM_CCLK_FREQ  => 0.0
    )
  port map
    (
    CFGCLK         => cfgclk,  -- Configuration clock only in master mode with persist enabled
    CFGMCLK        => open,    -- ~65MHz output
    EOS            => open,    -- End Of Startup sequence
    PREQ           => open,    -- PROGRAM_B pin signal if PROG_USR attribute is TRUE
    CLK            => '0',     -- User startup clock
    GSR            => '0',     -- Should be tied Low in most applications
    GTS            => '0',     -- Should be tied Low in most applications
    KEYCLEARB      => '1',     -- Active Low input to clear AES Decrypter Key
    PACK           => '0',     -- Only active if PROG_USR attribute is TRUE
    USRCCLKO       => '0',     -- Clock input to drive CCLK pin (e.g. access Flash)
    USRCCLKTS      => '0',     -- Low enables CCLK pin to drive with USRCCLKO value
    USRDONEO       => '1',     -- Input to drive the DONE pin
    USRDONETS      => '0'      -- Low enables DONE pin to drive with USRDONEO value
    );
  

BSCAN_A: BSCANE2
  generic map 
    (
    JTAG_CHAIN     => 1                -- Value for USER command. Possible values: (1,2,3 or 4).
    )
  port map 
    (
    CAPTURE        => bscan_capture_a,  -- 1-bit output: CAPTURE output from TAP controller.
    DRCK           => open,             -- 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or SHIFT are asserted.
    RESET          => open,             -- 1-bit output: Reset output for TAP controller.
    RUNTEST        => open,             -- 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
    SEL            => bscan_sel_a,      -- 1-bit output: USER active output.
    SHIFT          => bscan_shift_a,    -- 1-bit output: SHIFT output from TAP controller.
    TCK            => bscan_tck_a,      -- 1-bit output: Scan Clock output. Fabric connection to TAP Clock pin.
    TDI            => bscan_tdi_a,      -- 1-bit output: TDI output from TAP controller.
    TMS            => open,             -- 1-bit output: Test Mode Select input. Fabric connection to TAP.
    UPDATE         => bscan_update_a,   -- 1-bit output: UPDATE output from TAP controller
    TDO            => bscan_tdo_a       -- 1-bit input:  Data input for USER function.
    );


BSCAN_B: BSCANE2
  generic map 
    (
    JTAG_CHAIN     => 2                -- Value for USER command. Possible values: (1,2,3 or 4).
    )
  port map 
    (
    CAPTURE        => bscan_capture_b, -- 1-bit output: CAPTURE output from TAP controller.
    DRCK           => open,            -- 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or SHIFT are asserted.
    RESET          => open,            -- 1-bit output: Reset output for TAP controller.
    RUNTEST        => open,            -- 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
    SEL            => bscan_sel_b,     -- 1-bit output: USER active output.
    SHIFT          => open,            -- 1-bit output: SHIFT output from TAP controller.
    TCK            => bscan_tck_b,     -- 1-bit output: Scan Clock output. Fabric connection to TAP Clock pin.
    TDI            => open,            -- 1-bit output: TDI output from TAP controller.
    TMS            => open,            -- 1-bit output: Test Mode Select input. Fabric connection to TAP.
    UPDATE         => bscan_update_b,  -- 1-bit output: UPDATE output from TAP controller
    TDO            => bscan_tdo_b      -- 1-bit input:  Data input for USER function.
    );
-------------------------------------------------------------------------------
-- END OF INTERNAL SCRUBBING LOGIC
-------------------------------------------------------------------------------


end top;
